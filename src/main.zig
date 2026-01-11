const std = @import("std");
const builtin = @import("builtin");
const discord = @import("discord");
const Command = @import("commands/Command.zig");

pub const std_options: std.Options = .{
    .logFn = logFn,
};

pub fn logFn(comptime level: std.log.Level, comptime scope: @EnumLiteral(), comptime format: []const u8, args: anytype) void {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    var buffer: [128]u8 = undefined;
    const t = std.debug.lockStderr(&buffer).terminal();
    defer std.debug.unlockStderr();

    if (std.Io.Clock.real.now(io)) |now| {
        const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = @intCast(now.toSeconds()) };
        const month_day = epoch_seconds.getEpochDay().calculateYearDay().calculateMonthDay();

        t.setColor(.dim) catch {};
        t.writer.print("{t} {d} {d}:{d}:{d} ", .{
            month_day.month,
            month_day.day_index + 1,
            epoch_seconds.getDaySeconds().getHoursIntoDay(),
            epoch_seconds.getDaySeconds().getMinutesIntoHour(),
            epoch_seconds.getDaySeconds().getSecondsIntoMinute(),
        }) catch {};
        t.setColor(.reset) catch {};
    } else |_| {}

    t.setColor(switch (level) {
        .err => .red,
        .warn => .yellow,
        .info => .green,
        .debug => .magenta,
    }) catch {};
    t.setColor(.bold) catch {};
    t.writer.writeAll(level.asText()) catch {};
    t.setColor(.reset) catch {};
    t.setColor(.dim) catch {};
    t.setColor(.bold) catch {};
    if (scope != .default) t.writer.print("({t})", .{scope}) catch {};
    t.writer.writeAll(": ") catch {};
    t.setColor(.reset) catch {};
    t.writer.print(format ++ "\n", args) catch {};
}

const data_dir_path = "data/";

pub const Level = struct {
    xp: u64,
    role_id: ?u64 = null,

    pub const Storage = struct {
        guild_id: u64,
        channel_id: u64,
        table: []Level,
    };
};

pub const Profile = struct {
    id: u64 = 0,
    messages: u64 = 0,
    reactions: u64 = 0,
    xp: u64 = 0,
    level: u8 = 0,

    pub fn handleXp(self: *@This(), app: *App) bool {
        const cooldown = app.cooldowns.getPtr(self.id) orelse {
            app.cooldowns.put(app.allocator, self.id, std.time.Instant.now() catch std.mem.zeroes(std.time.Instant)) catch unreachable;
            return true;
        };
        const now = std.time.Instant.now() catch unreachable;
        const state = now.since(cooldown.*) > app.xp_balance.cooldown_ns;
        if (state) cooldown.* = now;
        return state;
    }
};

pub const App = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    profiles: std.AutoHashMapUnmanaged(discord.u64snowflake, Profile) = .empty,
    cooldowns: std.AutoHashMapUnmanaged(discord.u64snowflake, std.time.Instant) = .empty,
    xp_balance: XpBalance = .{},
    ready: bool = false,

    pub const XpBalance = struct {
        xp_per_message: u64 = 2,
        xp_per_reaction: u64 = 1,
        cooldown_ns: u64 = 376700,
    };

    pub fn close(self: *@This()) void {
        self.profiles.deinit(self.allocator);
    }

    pub fn save(self: *@This()) !void {
        std.Io.Dir.cwd().access(self.io, data_dir_path, .{}) catch |err|
            if (err == error.FileNotFound or err == error.AccessDenied)
                try std.Io.Dir.cwd().createDir(self.io, data_dir_path, .default_dir)
            else
                return err;

        var it = self.profiles.valueIterator();
        var profiles: std.ArrayList(Profile) = try .initCapacity(self.allocator, @intCast(self.profiles.count()));
        defer profiles.deinit(self.allocator);

        while (it.next()) |profile| {
            try profiles.append(self.allocator, profile.*);
        }

        const json = try std.json.Stringify.valueAlloc(self.allocator, profiles.items, .{ .whitespace = .indent_tab });
        defer self.allocator.free(json);
        try std.Io.Dir.cwd().writeFile(self.io, .{ .sub_path = data_dir_path ++ "profiles.json", .data = json });
    }

    pub fn load(self: *@This()) !void {
        try self.loadXpBalance();

        const sub_path = data_dir_path ++ "profiles.json";

        std.Io.Dir.cwd().access(self.io, sub_path, .{}) catch return;

        const file = try std.Io.Dir.cwd().readFileAlloc(self.io, sub_path, self.allocator, .unlimited);
        if (file.len == 0) return;

        const parsed: std.json.Parsed([]Profile) = try std.json.parseFromSlice([]Profile, self.allocator, file, .{});
        defer parsed.deinit();
        for (parsed.value) |profile| {
            try self.profiles.put(self.allocator, profile.id, profile);
        }
    }

    fn loadXpBalance(self: *@This()) !void {
        const sub_path = data_dir_path ++ "xp_balance.json";

        std.Io.Dir.cwd().access(self.io, sub_path, .{}) catch return std.log.warn("{s} not found. Will use defaults", .{sub_path});

        const file = try std.Io.Dir.cwd().readFileAlloc(self.io, sub_path, self.allocator, .unlimited);

        const parsed: std.json.Parsed(XpBalance) = try std.json.parseFromSlice(XpBalance, self.allocator, file, .{});
        defer parsed.deinit();
        self.xp_balance = parsed.value;
    }

    pub fn ensureProfile(self: *@This(), user_id: u64) void {
        if (self.profiles.get(user_id) == null) {
            self.profiles.put(self.allocator, user_id, .{ .id = user_id }) catch |err| std.log.err("{t} while adding new profile", .{err});
            std.log.info("added new profile: {d} {any}", .{ user_id, self.profiles.get(user_id) });
        }
    }

    pub fn levelService(client: discord.Client) !void {
        const scope = std.log.scoped(.role_service);
        const sub_path = data_dir_path ++ "level_table.json";
        const app = client.getData(@This()).?;

        std.Io.Dir.cwd().access(app.io, sub_path, .{}) catch return scope.warn("{s} not found. Level system will be turned off", .{sub_path});

        const storage: std.json.Parsed(Level.Storage) = storage: {
            const slice = try std.Io.Dir.cwd().readFileAlloc(app.io, sub_path, app.allocator, .unlimited);
            defer app.allocator.free(slice);

            break :storage try std.json.parseFromSlice(Level.Storage, app.allocator, slice, .{});
        };
        defer storage.deinit();

        while (!app.ready) {}
        std.log.info("started: level service loop", .{});

        while (true) {
            var it = app.profiles.valueIterator();
            while (it.next()) |profile| {
                for (storage.value.table, 0..) |element, level| {
                    if (profile.level > level or profile.xp < element.xp) continue;
                    if (element.role_id) |role_id| client.addGuildMemberRole(storage.value.guild_id, profile.id, role_id, &.{ .reason = "level up" }, null).toError() catch |err| {
                        scope.err("{t}: addGuildMemberRole", .{err});
                        continue;
                    };
                    var buf: [128]u8 = undefined;
                    const content: [:0]const u8 = std.fmt.bufPrintSentinel(&buf, "🥳 <@{d}> leveled up to level {d}!", .{ profile.id, profile.level + 1 }, 0) catch unreachable;
                    client.createMessage(storage.value.channel_id, &.{ .content = content.ptr }, null).toError() catch |err| {
                        scope.err("{t}: createMessage", .{err});
                        continue;
                    };
                    profile.level += 1;
                }
            }
            try app.io.sleep(.fromSeconds(1), .real);
        }
    }

    pub fn onReady(client: discord.Client, event: *const discord.Ready) callconv(.c) void {
        std.log.info("registering commands", .{});

        for (Command.commands) |command| {
            client.createGlobalApplicationCommand(event.application.id, &.{
                .type = .CHAT_INPUT,
                .name = command.name.ptr,
                .description = command.description.ptr,
                // .options: ApplicationCommand.Options
            }, null).toError() catch |err| {
                std.log.err("\t{s}: {t}", .{ command.name, err });
                continue;
            };

            std.log.info("\t{s}", .{command.name});
        }

        std.log.info("started: {s}", .{event.user.name});

        const app = client.getData(@This()).?;
        app.ready = true;
    }

    pub fn onInteraction(client: discord.Client, interaction: *const discord.Interaction) callconv(.c) void {
        const user = interaction.user orelse if (interaction.member) |member| member.user else null;
        client.getData(@This()).?.ensureProfile(user.?.id);
        Command.call(client, .fromInner(.{ .command = interaction }));
    }

    pub fn onMessage(client: discord.Client, event: *const discord.Message) callconv(.c) void {
        if (event.author.is_bot) return;

        if (std.mem.startsWith(u8, std.mem.span(event.content), Command.message_command_prefix)) return Command.call(client, .fromInner(.{ .message = event }));

        const app = client.getData(@This()).?;

        app.ensureProfile(event.author.id);

        const profile = app.profiles.getPtr(event.author.id).?;
        profile.messages += 1;
        if (profile.handleXp(app)) profile.xp += app.xp_balance.xp_per_message;

        app.save() catch |err| std.log.err("saving: {t}", .{err}); // TODO: move this out somewhere better
        if (std.mem.eql(u8, std.mem.span(event.content), "ping")) return discord.Message.create(client, event.channel_id, .{ .content = "pong!" }) catch return;
        if (std.mem.containsAtLeast(u8, std.mem.span(event.content), 1, "jimmy")) return discord.Message.create(client, event.channel_id, .{ .content = "Did someone say Jimmy?" }) catch return; // Jimmyfication

        const reaction_table: []const []const [:0]const u8 = &.{
            &.{ "6-7", "6️⃣", "7️⃣" },
            &.{ "std.Io", "🤡" },
            &.{ "typescript", "🤨", "😮", "😰" },
            &.{ "javascript", "🤨", "😮", "😰", "🤡" },
            &.{ "python", "😰" },
            &.{ "asm", "😰" },
            &.{ "raylib", "🤨" },

            &.{ "🔥", "🔥" },
            &.{ "zig", "🔥" },
            &.{ "c++", "🙄" },
        };

        for (reaction_table) |bad_word| {
            if (std.mem.containsAtLeast(u8, std.mem.span(event.content), 1, bad_word[0])) {
                for (bad_word[1..]) |emoji| {
                    _ = client.createReaction(event.channel_id, event.id, 0, emoji, null);
                }
            }
        }
    }

    pub fn onReactionAdd(client: discord.Client, event: *const discord.message_reaction.Add) callconv(.c) void {
        const app = client.getData(@This()).?;

        const profile = app.profiles.getPtr(event.user_id) orelse return;
        profile.reactions += 1;
        if (profile.handleXp(app)) {
            const amount = if (std.mem.eql(u8, std.mem.span(event.emoji.name), "🔥")) app.xp_balance.xp_per_reaction * 2 else app.xp_balance.xp_per_reaction;
            profile.xp +|= amount;
        }

        app.save() catch |err| std.log.err("saving: {t}", .{err}); // TODO: move this out somewhere better
    }

    pub fn onReactionRemove(client: discord.Client, event: *const discord.message_reaction.Remove) callconv(.c) void {
        const app = client.getData(@This()).?;

        const profile = app.profiles.getPtr(event.user_id) orelse return;
        profile.reactions -|= 1;
        if (profile.handleXp(app)) {
            const amount = if (std.mem.eql(u8, std.mem.span(event.emoji.name), "🔥")) app.xp_balance.xp_per_reaction * 2 else app.xp_balance.xp_per_reaction;
            profile.xp -|= amount;
        }

        app.save() catch |err| std.log.err("saving: {t}", .{err}); // TODO: move this out somewhere better

    }
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{ .safety = true }) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    var app: App = .{
        .allocator = allocator,
        .io = io,
    };
    defer app.close();
    try app.load();

    const bot_token = std.c.getenv("DISCORD_TOKEN") orelse @embedFile("TOKEN2");

    const client: discord.Client = discord.init(bot_token) orelse return error.InitDiscordClient;
    defer client.cleanup();

    const intents =
        discord.GATEWAY.GUILDS |
        discord.GATEWAY.GUILD_MEMBERS |
        discord.GATEWAY.GUILD_MESSAGES |
        discord.GATEWAY.GUILD_MESSAGE_REACTIONS |
        discord.GATEWAY.MESSAGE_CONTENT;

    client.addIntents(intents);

    client.setData(App, &app);

    client.setOnReady(App.onReady);
    client.setOnInteractionCreate(App.onInteraction);
    client.setOnMessageCreate(App.onMessage);
    client.setOnMessageReactionAdd(App.onReactionAdd);
    client.setOnMessageReactionRemove(App.onReactionRemove);

    var role_service_thread: std.Thread = try .spawn(.{ .allocator = allocator }, App.levelService, .{client});
    defer role_service_thread.join();

    try client.run().toError();

    try app.save();
}
