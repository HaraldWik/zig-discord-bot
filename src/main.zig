const std = @import("std");
const discord = @import("discord");
const Command = @import("commands/Command.zig");

pub const App = struct {
    pub fn onReady(client: discord.Client, event: *const discord.Ready) callconv(.c) void {
        for (Command.commands) |command| {
            var params: discord.CreateGuildApplicationCommand = .{
                .type = .CHAT_INPUT,
                .name = command.name.ptr,
                .description = command.description.ptr,
            };
            discord.create_guild_application_command(client, event.application.id, 1377723883612016783, &params, null).toError() catch |err| {
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

        if (command.onExecute) |onExecute| @call(.auto, onExecute, .{ client, interaction }) catch |err| {
            std.log.err("{t} in command {s}", .{ err, command.name });
        };
    }

    pub fn onMessage(client: discord.Client, event: *const discord.Message) callconv(.c) void {
        if (event.author.bot) return;
        std.debug.print("{d} {s} Message: \n", .{ event.author.id, event.content });

        const content: [*:0]const u8 = "Hello";

        var params: discord.Message.Create = .{
            .content = content,
        };

        _ = discord.create_message(client, event.channel_id, &params, null).log();

        if (!std.mem.eql(u8, std.mem.span(event.content), "ping")) return;
    }
};

pub fn main() !void {
    const BOT_TOKEN: [*:0]const u8 = @embedFile("TOKEN");

    const client: discord.Client = discord.init(BOT_TOKEN);

    discord.set_on_ready(client, App.onReady);
    discord.set_on_interaction_create(client, App.onInteraction);
    discord.set_on_message_create(client, App.onMessage);

    try discord.run(client).toError();

    std.debug.print("Exit\n", .{});

    return error.Fc;
}
