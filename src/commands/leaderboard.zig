const std = @import("std");
const Command = @import("Command.zig");
// const discord = @import("../discord.zig");
const discord = @import("discord");
const App = @import("../main.zig").App;
const Profile = @import("../main.zig").Profile;

pub const command: Command = .{
    .name = "leaderboard",
    .description = "See who is the best in all aspects",
    .onExecute = onExecute,
    .options = &.{
        .{
            .name = "limit",
            .description = "Maximum number of entries to display",
            .type = .NUMBER,
        },
    },
};

pub const default_leaderboard_limit: std.Io.Limit = .limited(5);

pub fn onExecute(client: discord.Client, interaction: Command.Interaction) !void {
    const limit: ?std.Io.Limit = if (interaction.option(.limit)) |limit_str|
        .limited(try std.fmt.parseInt(std.meta.Tag(std.Io.Limit), limit_str, 10))
    else
        null;
    if (limit orelse default_leaderboard_limit == .nothing) return error.LimitCanNotBeNothing;

    const app: *App = client.getData(App).?;

    if (app.profiles.count() == 0) return interaction.respond(client, "Leaderboard is empty", .{});

    var leaderboard: std.ArrayList(Profile) = try .initCapacity(app.allocator, @intCast(app.profiles.count()));
    defer leaderboard.deinit(app.allocator);

    var it = app.profiles.valueIterator();
    leaderboard.appendSliceAssumeCapacity(it.items[0..app.profiles.count()]);

    std.sort.block(Profile, leaderboard.items, {}, struct {
        pub fn greaterThan(_: void, a: Profile, b: Profile) bool {
            return a.xp > b.xp;
        }
    }.greaterThan);

    var buf: [256]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buf);
    try writer.writeAll("Leaderboard\n");
    for (leaderboard.items[0..@min(@intFromEnum(limit orelse default_leaderboard_limit), leaderboard.items.len)], 0..) |profile, i| {
        const emoji = switch (i) {
            0 => "🥇",
            1 => "🥈",
            2 => "🥉",
            99 => "💯",
            else => "🏅",
        };

        try writer.print("{s} <@{d}>: {d}xp\n", .{ emoji, profile.id, profile.xp });
    }

    try writer.writeByte(0);

    try interaction.respond(client, "{s}", .{writer.buffered()});
}
