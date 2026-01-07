const std = @import("std");
const builtin = @import("builtin");
const discord = @import("discord");
const Command = @import("commands/Command.zig");

pub const Profile = packed struct {
    messages: u64 = 0,

    pub fn encode(self: @This()) [@sizeOf(@This())]u8 {
        var buffer: [@sizeOf(@This())]u8 = undefined;

        std.mem.writeInt(u64, buffer[0..8], self.messages, builtin.cpu.arch.endian());

        return buffer;
    }

    pub fn decode(buf: []const u8) @This() {
        var self: @This() = .{};

        self.messages = std.mem.readInt(u64, buf[0..8], builtin.cpu.arch.endian());

        return self;
    }
};

const data_dir = "data/";

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
        try writer.flush();
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

    pub fn onReady(client: discord.Client, event: *const discord.Ready) callconv(.c) void {
        for (Command.commands) |command| {
            var params: discord.CreateGuildApplicationCommand = .{
                .type = .CHAT_INPUT,
                .name = command.name.ptr,
                .description = command.description.ptr,
            };
            client.createGuildApplicationCommand(event.application.id, 1377723883612016783, &params, null).toError() catch |err| {
                std.log.err("{t} while creating command", .{err});
            };
        }
        std.log.info("started: {s}", .{event.user.name});
    }

    pub fn onInteraction(client: discord.Client, interaction: *const discord.Interaction) callconv(.c) void {
        if (interaction.type != .APPLICATION_COMMAND) return;

        const command: Command = for (Command.commands) |command| {
            if (std.mem.eql(u8, std.mem.span(interaction.data.?.name), command.name)) break command;
        } else return;

        if (command.onExecute) |onExecute| onExecute(client, interaction) catch |err| {
            std.log.err("{t} in command {s}", .{ err, command.name });
        };
    }

    pub fn onMessage(client: discord.Client, event: *const discord.Message) callconv(.c) void {
        if (event.author.bot) return;

        const app = client.getData(App).?;

        if (app.profiles.get(event.author.id) == null) app.profiles.put(app.allocator, event.author.id, .{}) catch |err| std.log.err("adding new stat: {t}", .{err});

        if (app.profiles.get(event.author.id)) |stat| {
            var new_stat = stat;
            new_stat.messages += 1;
            app.profiles.put(app.allocator, event.author.id, new_stat) catch return;
            app.save() catch |err| std.log.err("save failed: {t}", .{err});
        }

        std.log.info("{s} {?}", .{ event.author.name, app.profiles.get(event.author.id) });
    }
};

// var sig_count = std.atomic.Value(u8).init(0);

// fn signal_handler(sig: std.posix.SIG, info: *const std.posix.siginfo_t, ctx_ptr: ?*anyopaque) callconv(.c) void {
//     _ = sig;
//     _ = info;
//     _ = ctx_ptr;
//     const n = sig_count.fetchAdd(1, .acq_rel);
//     if (n >= 1) std.process.exit(1);
// }

pub fn main() !void {
    // if (builtin.os.tag != .windows) {
    //     const act = std.posix.Sigaction{
    //         .handler = .{ .sigaction = signal_handler },
    //         .mask = std.posix.sigemptyset(),
    //         .flags = std.os.linux.SA.RESTART,
    //     };
    //     std.posix.sigaction(.INT, &act, null);
    // }

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

    client.setData(App, &app);

    client.setOnReady(App.onReady);
    client.setOnInteractionCreate(App.onInteraction);
    client.setOnMessageCreate(App.onMessage);
    try client.run().toError();
}
