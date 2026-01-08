const std = @import("std");
const Command = @import("Command.zig");
const discord = @import("discord");
const App = @import("../main.zig").App;

pub const command: Command = .{
    .name = "profile",
    .description = "Check you`re profile`s stats!",
    .onExecute = onExecute,
};

pub fn onExecute(client: discord.Client, interaction: Command.Interaction) !void {
    const app: *App = client.getData(App).?;

    const profile = app.profiles.getPtr(interaction.user.id) orelse return interaction.respond(client, "You need to write a message to get a profile");

    var buf: [128]u8 = undefined;
    const content = try std.fmt.bufPrintZ(&buf, "{s}\nmessages: {d}\nreactions: {d}\nxp: {d}", .{ profile.getName(), profile.messages, profile.reactions, profile.xp });

    try interaction.respond(client, content);
}
