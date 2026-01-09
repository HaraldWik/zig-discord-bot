const std = @import("std");
const builtin = @import("builtin");
const discord = @import("discord");
const Command = @import("commands/Command.zig");

pub const std_options: std.Options = .{
    .logFn = logFn,
};

pub fn logFn(comptime level: std.log.Level, comptime scope: @EnumLiteral(), comptime format: []const u8, args: anytype) void {
    // TODO: add timestamp
    std.log.defaultLog(level, scope, format, args);
}

const data_dir = "data/";
const guild_id = 1377723883612016783;

pub const Profile = struct {
    id: u64 = 0,
    messages: u64 = 0,
    reactions: u64 = 0,
    xp: u64 = 0,

    pub const balance = struct {
        const xp_per_message: u64 = 2;
        const xp_per_reaction: u64 = 1;
        const cooldown_s = std.time.ns_per_ms * 3767;
    };

    pub fn handleXp(self: *@This(), app: *App) bool {
        const cooldown = app.cooldowns.getPtr(self.id) orelse {
            app.cooldowns.put(app.allocator, self.id, std.time.Instant.now() catch std.mem.zeroes(std.time.Instant)) catch unreachable;
            return true;
        };
        const now = std.time.Instant.now() catch unreachable;
        const state = now.since(cooldown.*) > balance.cooldown_s;
        if (state) cooldown.* = now;
        return state;
    }
};

pub const App = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    profiles: std.AutoHashMapUnmanaged(discord.u64snowflake, Profile) = .empty,
    cooldowns: std.AutoHashMapUnmanaged(discord.u64snowflake, std.time.Instant) = .empty,

    pub fn close(self: *@This()) void {
        self.profiles.deinit(self.allocator);
    }

    pub fn save(self: *@This()) !void {
        var it = self.profiles.valueIterator();
        const json = try std.json.Stringify.valueAlloc(self.allocator, it.items[0..self.profiles.count()], .{ .whitespace = .indent_tab });
        defer self.allocator.free(json);
        try std.Io.Dir.cwd().writeFile(self.io, .{ .sub_path = data_dir ++ "profiles.json", .data = json });
    }

    pub fn load(self: *@This()) !void {
        var file = std.Io.Dir.cwd().openFile(self.io, data_dir ++ "profiles.json", .{}) catch |err| if (err == error.FileNotFound) return else return err;
        defer file.close(self.io);
        var buffer: []u8 = try self.allocator.alloc(u8, (try file.stat(self.io)).size);
        defer self.allocator.free(buffer);
        var reader = file.reader(self.io, buffer);
        const slice = try reader.interface.take(buffer.len);

        const parsed: std.json.Parsed([]Profile) = try std.json.parseFromSlice([]Profile, self.allocator, slice, .{});
        defer parsed.deinit();
        for (parsed.value) |profile| {
            try self.profiles.put(self.allocator, profile.id, profile);
        }
    }

    pub fn onReady(client: discord.Client, event: *const discord.Ready) callconv(.c) void {
        std.log.info("registering commands", .{});

        for (Command.commands) |command| {
            // createGlobalApplicationCommand
            client.createGuildApplicationCommand(event.application.id, 1377723883612016783, &.{
                .type = .CHAT_INPUT,
                .name = command.name.ptr,
                .description = command.description.ptr,
            }, null).toError() catch |err| {
                std.log.err("\t{s}: {t}", .{ command.name, err });
                continue;
            };

            std.log.info("\t{s}", .{command.name});
        }

        std.log.info("started: {s}", .{event.user.name});
    }

    pub fn onInteraction(client: discord.Client, interaction: *const discord.Interaction) callconv(.c) void {
        Command.call(client, .fromInner(.{ .command = interaction }));
    }

    pub fn onMessage(client: discord.Client, event: *const discord.Message) callconv(.c) void {
        if (event.author.is_bot) return;

        if (std.mem.startsWith(u8, std.mem.span(event.content), Command.message_command_prefix)) return Command.call(client, .fromInner(.{ .message = event }));

        const app = client.getData(App).?;

        if (app.profiles.get(event.author.id) == null) {
            app.profiles.put(app.allocator, event.author.id, .{ .id = event.author.id }) catch |err| std.log.err("{t} while adding new profile", .{err});
        }

        const profile = app.profiles.getPtr(event.author.id).?;
        profile.messages += 1;
        if (profile.handleXp(app)) profile.xp += Profile.balance.xp_per_message;

        app.save() catch |err| std.log.err("saving: {t}", .{err}); // TODO: move this out somewhere better
        if (std.mem.eql(u8, std.mem.span(event.content), "ping")) return discord.Message.create(client, event.channel_id, .{ .content = "pong!" }) catch return;
        if (std.mem.containsAtLeast(u8, std.mem.span(event.content), 1, "jimmy")) return discord.Message.create(client, event.channel_id, .{ .content = "Did someone say Jimmy?" }) catch return; // Jimmyfication

        const bad_words: []const []const [:0]const u8 = &.{
            &.{ "67", "6️⃣", "7️⃣" },
            &.{ "6-7", "6️⃣", "7️⃣" },
            &.{ "std.Io", "🤡" },
            &.{ "typescript", "🤨", "😮", "😰", "🤡", "🤢", "🤮", "🚽", "🤬" },
            &.{ "javascript", "🤨", "😮", "😰", "🤡", "🤢", "🤮", "🚽", "🤬" },
            &.{ "python", "🤢" },
        };

        for (bad_words) |bad_word| {
            if (std.mem.containsAtLeast(u8, std.mem.span(event.content), 1, bad_word[0])) {
                for (bad_word[1..]) |emoji| {
                    _ = client.createReaction(event.channel_id, event.id, 0, emoji, null);
                }
            }
        }
    }

    pub fn onReactionAdd(client: discord.Client, event: *const discord.message_reaction.Add) callconv(.c) void {
        const app = client.getData(App).?;

        const profile = app.profiles.getPtr(event.user_id) orelse return;
        profile.reactions += 1;
        if (profile.handleXp(app)) {
            const amount = if (std.mem.eql(u8, std.mem.span(event.emoji.name), "🔥")) Profile.balance.xp_per_reaction * 2 else Profile.balance.xp_per_reaction;
            profile.xp +|= amount;
        }

        app.save() catch |err| std.log.err("saving: {t}", .{err}); // TODO: move this out somewhere better
    }

    pub fn onReactionRemove(client: discord.Client, event: *const discord.message_reaction.Remove) callconv(.c) void {
        const app = client.getData(App).?;

        const profile = app.profiles.getPtr(event.user_id) orelse return;
        profile.reactions -|= 1;
        if (profile.handleXp(app)) {
            const amount = if (std.mem.eql(u8, std.mem.span(event.emoji.name), "🔥")) Profile.balance.xp_per_reaction * 2 else Profile.balance.xp_per_reaction;
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

    const bot_token = std.c.getenv("DISCORD_TOKEN") orelse @embedFile("TOKEN");

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
    try client.run().toError();

    try app.save();
}
