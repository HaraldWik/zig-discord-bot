const std = @import("std");
const discord = @import("discord");
const Command = @import("commands/Command.zig");

pub const Stat = struct {
    messages: u64 = 0,
};

pub const App = struct {
    config: Config,
    allocator: std.mem.Allocator,
    stats: std.AutoHashMapUnmanaged(discord.u64snowflake, Stat) = .empty,

    pub const Config = struct {
        data_dir: []const u8 = "data",
        is_good: bool = false,
    };

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
        const app = client.getData(App).?;
        if (event.author.bot) return;
        std.debug.print("{d} {s} Message: \n", .{ event.author.id, event.content });

        if (app.stats.get(event.author.id)) |stat| {
            var new_stat = stat;
            new_stat.messages += 1;
            app.stats.put(app.allocator, event.author.id, new_stat) catch return;
        }

        const content: [*:0]const u8 = "Hello";

        var params: discord.Message.Create = .{
            .content = content,
        };

        _ = client.createMessage(event.channel_id, &params, null).log();

        if (!std.mem.eql(u8, std.mem.span(event.content), "ping")) return;
    }
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = std.process.args();
    _ = args.skip();

    var config: App.Config = .{};
    while (args.next()) |arg| {
        if (!std.mem.eql(u8, arg[0..2], "--")) continue;

        const equal_index = std.mem.indexOfScalar(u8, arg, '=') orelse break;
        inline for (@typeInfo(App.Config).@"struct".fields) |current_field| {
            const field = arg[2..equal_index];
            const value = arg[equal_index + 1 ..];

            if (std.mem.eql(u8, field, current_field.name)) {
                if (switch (@typeInfo(current_field.type)) {
                    .bool => if (std.mem.eql(u8, value, "true")) true else if (std.mem.eql(u8, value, "false")) false else null,
                    // .pointer => |ptr| if (ptr.child == u8) str: {
                    //     std.debug.print("HELO\n", .{});
                    //     if (value.len < 2 or value[0] != '"') return error.NoStartingQuote;
                    //     const end = std.mem.indexOfScalar(u8, value[1..], '"') orelse return error.NoEndingQuote;
                    //     break :str value[1..end];
                    // } else null,
                    else => null,
                }) |val| @field(config, current_field.name) = val;
            }
        }
    }

    var app: App = .{
        .config = config,
        .allocator = allocator,
    };
    defer app.stats.deinit(allocator);

    const BOT_TOKEN: [*:0]const u8 = @embedFile("TOKEN");

    const client: discord.Client = discord.init(BOT_TOKEN) orelse return error.InitDiscordClient;
    defer client.cleanup();

    client.setData(App, &app);

    client.setOnReady(App.onReady);
    client.setOnInteractionCreate(App.onInteraction);
    client.setOnMessageCreate(App.onMessage);

    try client.run().toError();
}
