// Thanks to https://github.com/sebastianoff for formating solutions

const std = @import("std");
const Command = @import("Command.zig");
const discord = @import("discord");

pub const command: Command = .{
    .name = "help",
    .description = "Get some help",
    .onExecute = onExecute,
};

pub fn onExecute(client: discord.Client, interaction: Command.Interaction) !void {
    var buf: [256]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buf);

    // try writer.writeAll(
    //     \\Usage: [command] [options]
    //     \\__To call a command, you can use either a__
    //     \\slash command </command_name> or a message command <!command_name>.
    //     \\
    //     \\Some options have autocomplete. To use autocomplete with a message command,
    //     \\type !command_name autocomplete to see the available choices.
    // );

    try writer.writeAll("Commands:\n\n");
    for (Command.commands) |command_| {
        if (std.mem.eql(u8, command_.name, "help")) continue;
        try writer.print("> /{s} ", .{command_.name});
        for (command_.options) |option| {
            try writer.print("[{s}]", .{option.name});
        }
        try writer.print("\n**{s}**\n\n", .{command_.description});
    }

    try interaction.respond(client, "{s}", .{writer.buffered()});
}

// > /command_name [option1] [option2] [option3] ...
// > description
// >
