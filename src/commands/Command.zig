const std = @import("std");
const discord = @import("discord");

name: [:0]const u8,
description: [:0]const u8,
onExecute: ?Execute = null,

pub const commands: []const @This() = &.{
    @import("globglogabgelab.zig").command,
    @import("profile.zig").command,
    @import("leaderboard.zig").command,
};

pub const Execute = *const fn (client: discord.Client, interaction: Interaction) anyerror!void;

pub const Interaction = struct {
    id: u64,
    user: *discord.User,
    member: ?*discord.guild_member,
    channel_id: u64,
    guild_id: u64,
    application_id: u64,

    internal: Internal,

    pub const Internal = union(enum) {
        command: *const discord.Interaction,
        message: *const discord.Message,

        pub fn toInteraction(self: @This()) Interaction {
            return switch (self) {
                .command => |interaction| .{
                    .internal = self,
                    .id = interaction.id,
                    .user = interaction.user,
                    .member = interaction.member,
                    .channel_id = interaction.channel_id,
                    .guild_id = interaction.guild_id,
                    .application_id = interaction.application_id,
                },
                .message => |interaction| .{
                    .internal = self,
                    .id = interaction.id,
                    .user = interaction.author,
                    .member = interaction.member,
                    .channel_id = interaction.channel_id,
                    .guild_id = interaction.guild_id,
                    .application_id = interaction.application_id,
                },
            };
        }
    };

    pub fn respond(self: @This(), client: discord.Client, content: [:0]const u8) !void {
        switch (self.internal) {
            .command => |interaction| try interaction.respond(client, .{ .data = &.{ .content = content.ptr } }, null),
            .message => |interaction| try discord.Message.create(client, interaction.channel_id, .{ .content = content }),
        }
    }
};

pub fn call(client: discord.Client, command_name: [*:0]const u8, interaction: Interaction) void {
    for (commands) |command| {
        if (!std.mem.eql(u8, std.mem.span(command_name), command.name)) continue;
        std.log.info("command '{s}'' called by {s}", .{ command_name, interaction.user.name });
        if (command.onExecute) |onExecute| onExecute(client, interaction) catch |err| {
            std.log.err("{t} when calling command {s}", .{ err, command_name });
            var buf: [128]u8 = undefined;
            const content = std.fmt.bufPrintZ(&buf, "Error {t} when calling command {s} ", .{ err, command_name }) catch unreachable;
            interaction.respond(client, content) catch {};
        };
    }
}
