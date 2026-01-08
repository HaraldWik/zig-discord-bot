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
    name: [33]u8 = @splat(0),
    cooldown: std.time.Instant = std.mem.zeroes(std.time.Instant),

    pub const save_size = @sizeOf(@This()) - @sizeOf(std.time.Instant);

    pub const balance = struct {
        const xp_per_message: u64 = 2;
        const xp_per_reaction: u64 = 1;
        const cooldown_s = std.time.ns_per_ms * 3767;
    };

    pub fn encode(self: @This()) [save_size]u8 {
        var buffer: [save_size]u8 = undefined;

        std.mem.writeInt(u64, buffer[0..8], self.id, builtin.cpu.arch.endian());
        std.mem.writeInt(u64, buffer[8..16], self.messages, builtin.cpu.arch.endian());
        std.mem.writeInt(u64, buffer[16..24], self.reactions, builtin.cpu.arch.endian());
        std.mem.writeInt(u64, buffer[24..32], self.xp, builtin.cpu.arch.endian());
        @memcpy(buffer[32..65], self.name[0..]);

        return buffer;
    }

    pub fn decode(buf: [save_size]u8) @This() {
        var self: @This() = .{
            .id = std.mem.readInt(u64, buf[0..8], builtin.cpu.arch.endian()),
            .messages = std.mem.readInt(u64, buf[8..16], builtin.cpu.arch.endian()),
            .reactions = std.mem.readInt(u64, buf[16..24], builtin.cpu.arch.endian()),
            .xp = std.mem.readInt(u64, buf[24..32], builtin.cpu.arch.endian()),
        };
        const name = buf[32..65];
        @memcpy(self.name[0..name.len], name);
        return self;
    }

    pub fn handleXp(self: *@This()) bool {
        const now = std.time.Instant.now() catch unreachable;
        const state = now.since(self.cooldown) > balance.cooldown_s;
        if (state) self.cooldown = now;
        return state;
    }

    pub fn getName(self: @This()) [:0]const u8 {
        const len = for (self.name, 0..) |char, i| {
            if (char == 0) break i;
        } else 0;
        return self.name[0..len :0];
    }
};

pub const App = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    profiles: std.AutoHashMapUnmanaged(discord.u64snowflake, Profile) = .empty,

    pub fn close(self: *@This()) void {
        self.profiles.deinit(self.allocator);
    }

    pub fn save(self: *@This()) !void {
        var allocating: std.Io.Writer.Allocating = .init(self.allocator);
        defer allocating.deinit();
        const writer: *std.Io.Writer = &allocating.writer;

        var it = self.profiles.iterator();
        while (it.next()) |entry| {
            try writer.writeAll(&entry.value_ptr.encode());
        }

        try std.Io.Dir.cwd().writeFile(self.io, .{ .sub_path = data_dir ++ "profiles.bin", .data = writer.buffered() });
    }

    pub fn load(self: *@This()) !void {
        var file = std.Io.Dir.cwd().openFile(self.io, data_dir ++ "profiles.bin", .{}) catch |err| if (err == error.FileNotFound) return else return err;
        defer file.close(self.io);

        var buffer: [Profile.save_size + 1]u8 = undefined;
        var file_reader = file.reader(self.io, &buffer);
        const reader = &file_reader.interface;

        std.log.info("loading data", .{});
        while (true) {
            var slice = reader.take(buffer.len) catch |err| if (err == error.EndOfStream) break else return err;
            const profile: Profile = .decode(slice[0..Profile.save_size]);
            try self.profiles.put(self.allocator, profile.id, profile);
            std.log.info("\tprofile: {s}, messages: {d}, reactions: {d}, xp: {d}", .{ profile.getName(), profile.messages, profile.reactions, profile.xp });
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
        if (interaction.type != .APPLICATION_COMMAND) return;
        std.debug.print("interaction: {any}\n", .{interaction.*});

        Command.call(client, interaction.data.?.name, Command.Interaction.Internal.toInteraction(.{ .command = interaction }));
    }

    pub fn onMessage(client: discord.Client, event: *const discord.Message) callconv(.c) void {
        if (event.author.is_bot) return;

        if (event.content[0] == '!') return Command.call(client, event.content[1..], Command.Interaction.Internal.toInteraction(.{ .message = event }));

        const app = client.getData(App).?;

        if (app.profiles.get(event.author.id) == null) {
            var new_profile: Profile = .{ .id = event.author.id };
            const name = std.mem.span(if (event.member != null and event.member.?.nick != null)
                event.member.?.nick.?
            else
                event.author.name); // fallback to global username
            @memcpy(new_profile.name[0..name.len], name);
            app.profiles.put(app.allocator, new_profile.id, new_profile) catch |err| std.log.err("{t} while adding new profile", .{err});
        }

        const profile = app.profiles.getPtr(event.author.id).?;
        profile.messages += 1;
        if (profile.handleXp()) profile.xp += Profile.balance.xp_per_message;

        app.save() catch |err| std.log.err("saving: {t}", .{err}); // TODO: move this out somewhere better

        if (std.mem.eql(u8, std.mem.span(event.content), "ping")) discord.Message.create(client, event.channel_id, .{ .content = "pong!" }) catch return;
        if (std.mem.eql(u8, std.mem.span(event.content), "ding")) discord.Message.create(client, event.channel_id, .{ .content = "dong!" }) catch return;
    }

    pub fn onReactionAdd(client: discord.Client, event: *const discord.message_reaction.Add) callconv(.c) void {
        const app = client.getData(App).?;

        const profile = app.profiles.getPtr(event.user_id) orelse return;
        profile.reactions += 1;
        if (profile.handleXp()) {
            const amount = if (std.mem.eql(u8, std.mem.span(event.emoji.name), "🔥")) Profile.balance.xp_per_reaction * 2 else Profile.balance.xp_per_reaction;
            profile.xp +|= amount;
        }

        app.save() catch |err| std.log.err("saving: {t}", .{err}); // TODO: move this out somewhere better
    }

    pub fn onReactionRemove(client: discord.Client, event: *const discord.message_reaction.Remove) callconv(.c) void {
        const app = client.getData(App).?;

        const profile = app.profiles.getPtr(event.user_id) orelse return;
        profile.reactions -|= 1;
        if (profile.handleXp()) {
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

    const BOT_TOKEN: [*:0]const u8 = @embedFile("TOKEN");

    const client: discord.Client = discord.init(BOT_TOKEN) orelse return error.InitDiscordClient;
    defer client.cleanup();

    const intents =
        discord.GATEWAY.GUILDS |
        // discord.GATEWAY.GUILD_MEMBERS |
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
