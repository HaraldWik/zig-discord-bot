const std = @import("std");
const builtin = @import("builtin");
const discord = @import("discord");
const Command = @import("commands/Command.zig");

const data_dir = "data/";
const guild_id = 1377723883612016783;

pub const Profile = struct {
    cooldown: std.time.Instant = std.mem.zeroes(std.time.Instant),
    messages: u64 = 0,
    reactions: u64 = 0,
    xp: u64 = 0,

    pub const balance = struct {
        const xp_per_message: u64 = 2;
        const xp_per_reaction: u64 = 1;
        const cooldown_s = std.time.ns_per_ms * 3767;
    };

    pub fn encode(self: @This()) [@sizeOf(@This())]u8 {
        var buffer: [@sizeOf(@This())]u8 = undefined;

        std.mem.writeInt(u64, buffer[0..8], self.messages, builtin.cpu.arch.endian());
        std.mem.writeInt(u64, buffer[8..16], self.reactions, builtin.cpu.arch.endian());
        std.mem.writeInt(u64, buffer[16..24], self.xp, builtin.cpu.arch.endian());

        return buffer;
    }

    pub fn decode(buf: []const u8) @This() {
        return .{
            .messages = std.mem.readInt(u64, buf[0..8], builtin.cpu.arch.endian()),
            .reactions = std.mem.readInt(u64, buf[8..16], builtin.cpu.arch.endian()),
            .xp = std.mem.readInt(u64, buf[16..24], builtin.cpu.arch.endian()),
        };
    }

    pub fn handleXp(self: *@This()) bool {
        const now = std.time.Instant.now() catch unreachable;
        const state = now.since(self.cooldown) > balance.cooldown_s;
        if (state) self.cooldown = now;
        return state;
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
            try writer.writeAll(&std.mem.toBytes(entry.key_ptr.*));
            try writer.writeAll(&entry.value_ptr.encode());
        }

        try std.Io.Dir.cwd().writeFile(self.io, .{ .sub_path = data_dir ++ "profiles.bin", .data = writer.buffered() });
    }

    pub fn load(self: *@This()) !void {
        var file = std.Io.Dir.cwd().openFile(self.io, data_dir ++ "profiles.bin", .{}) catch |err| if (err == error.FileNotFound) return else return err;
        defer file.close(self.io);

        var buffer: [@sizeOf(u64) + @sizeOf(Profile)]u8 = undefined;
        var file_reader = file.reader(self.io, &buffer);
        const reader = &file_reader.interface;
        std.log.info("loading data", .{});

        while (true) {
            var slice = reader.take(buffer.len) catch |err| if (err == error.EndOfStream) break else return err;
            const key = std.mem.readInt(u64, slice[0..8], builtin.cpu.arch.endian());
            const value: Profile = .decode(slice[8..]);
            try self.profiles.put(self.allocator, key, value);
            std.log.info("\tprofile: {d} {any}", .{ key, value });
        }
    }

    pub fn getProfile(self: *@This(), id: discord.u64snowflake) *Profile {
        if (self.profiles.get(id) == null) self.profiles.put(self.allocator, id, .{}) catch |err| std.log.err("{t} while adding new profile", .{err});
        return self.profiles.getPtr(id).?;
    }

    pub fn onReady(client: discord.Client, event: *const discord.Ready) callconv(.c) void {
        std.log.info("registering commands", .{});

        for (Command.commands) |command| {
            _ = command;
            _ = client;
            // createGlobalApplicationCommand
            // client.createGuildApplicationCommand(event.application.id, 1377723883612016783, &.{
            //     .type = .CHAT_INPUT,
            //     .name = command.name.ptr,
            //     .description = command.description.ptr,
            // }, null).toError() catch |err| {
            //     std.log.err("\t{s}: {t}", .{ command.name, err });
            //     continue;
            // };

            // std.log.info("\t{s}", .{command.name});
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
        const app = client.getData(App).?;

        const profile = app.getProfile(event.author.id);
        profile.messages += 1;
        if (profile.handleXp()) profile.xp += Profile.balance.xp_per_message;

        app.save() catch |err| std.log.err("saving: {t}", .{err}); // TODO: move this out somewhere better

        if (std.mem.eql(u8, std.mem.span(event.content), "ping")) discord.Message.create(client, event.channel_id, .{ .content = "pong!" }) catch return;
        if (std.mem.eql(u8, std.mem.span(event.content), "ding")) discord.Message.create(client, event.channel_id, .{ .content = "dong!" }) catch return;

        if (event.content[0] == '!') Command.call(client, event.content[1..], Command.Interaction.Internal.toInteraction(.{ .message = event }));
    }

    pub fn onReactionAdd(client: discord.Client, event: *const discord.message_reaction.Add) callconv(.c) void {
        const app = client.getData(App).?;

        const profile = app.getProfile(event.user_id);
        profile.reactions += 1;
        if (profile.handleXp()) profile.xp +|= Profile.balance.xp_per_reaction;

        app.save() catch |err| std.log.err("saving: {t}", .{err}); // TODO: move this out somewhere better
    }

    pub fn onReactionRemove(client: discord.Client, event: *const discord.message_reaction.Remove) callconv(.c) void {
        const app = client.getData(App).?;

        const profile = app.getProfile(event.user_id);
        profile.reactions -|= 1;
        if (profile.handleXp()) profile.xp -|= Profile.balance.xp_per_reaction;

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
