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
};

const leaderboard_count = 5;

pub fn onExecute(client: discord.Client, interaction: Command.Interaction) !void {
    const app: *App = client.getData(App).?;

    var leaderboard: std.ArrayList(@TypeOf(app.profiles).Entry) = try .initCapacity(app.allocator, @intCast(app.profiles.count()));
    defer leaderboard.deinit(app.allocator);

    var it = app.profiles.iterator();
    while (it.next()) |entry| {
        leaderboard.appendAssumeCapacity(entry);
    }

    std.sort.block(@TypeOf(app.profiles).Entry, leaderboard.items, {}, struct {
        pub fn greaterThan(context: void, a: @TypeOf(app.profiles).Entry, b: @TypeOf(app.profiles).Entry) bool {
            _ = context;
            return a.value_ptr.xp > b.value_ptr.xp;
        }
    }.greaterThan);

    var buf: [256]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&buf);
    try writer.writeAll("Leaderboard\n");
    for (0..@min(leaderboard_count, leaderboard.items.len)) |i| {
        const entry = leaderboard.items[i];
        try writer.print("#{d} {s}: {d}xp\n", .{ i + 1, entry.value_ptr.getName(), entry.value_ptr.xp });
    }

    try writer.writeByte(0);

    try interaction.respond(client, @ptrCast(writer.buffered()));
}
