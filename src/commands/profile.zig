const std = @import("std");
const Command = @import("Command.zig");
const discord = @import("discord");
const App = @import("../main.zig").App;

pub const command: Command = .{
    .name = "profile",
    .description = "Check you`re profile`s stats!",
    .onExecute = onExecute,
    .options = &.{
        .{
            .name = "user",
            .description = "The user profile you want to seeeeeeeeeeee",
            .type = .USER,
        },
    },
};

pub fn onExecute(client: discord.Client, interaction: Command.Interaction) !void {
    const app: *App = client.getData(App).?;
    const user_id = if (interaction.option(.user)) |user_id_str| try std.fmt.parseInt(u64, user_id_str, 10) else interaction.user.id;

    const profile = app.profiles.getPtr(user_id) orelse return interaction.respond(client, "<@{d}> needs to write a message to get a profile", .{user_id});

    try interaction.respond(client, "<@{d}>\nmessages: {d}\nreactions: {d}\nxp: {d}", .{ profile.id, profile.messages, profile.reactions, profile.xp });
}
