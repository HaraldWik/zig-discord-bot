const std = @import("std");
const discord = @import("discord");

const Command = @This();

name: [:0]const u8,
description: [:0]const u8,
onExecute: ?Execute = null,
onAutocomplete: ?Autocomplete = null, // @import("globglogabgelab.zig").onAutocomplete,
options: []const discord.ApplicationCommand.Option = &.{},

pub const commands: []const @This() = &.{
    @import("globglogabgelab.zig").command,
    @import("profile.zig").command,
    @import("leaderboard.zig").command,
    @import("meow.zig").command,
};

pub const Execute = *const fn (client: discord.Client, interaction: Interaction) anyerror!void;
pub const Autocomplete = *const fn (client: discord.Client, interaction: Interaction) anyerror!void;
pub const AutocompleteChoice = extern struct {
    name: [*:0]const u8,
    value: [*:0]const u8,

    pub const max_count = 25;
};

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
                    .user = interaction.user orelse interaction.member.?.user,
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

    pub fn option(self: @This(), comptime name: @EnumLiteral()) ?[:0]const u8 {
        switch (self.internal) {
            .command => |interaction| {
                if (interaction.data == null) return null;
                const options = interaction.data.?.options orelse return null;

                for (options.array[0..@intCast(options.size)]) |opt| {
                    if (std.mem.eql(u8, std.mem.span(opt.name), @tagName(name))) return std.mem.span(opt.value);
                }
            },
            .message => |interaction| {
                _ = interaction;
            },
        }
        return null;
    }

    pub fn focused(self: @This()) ?[:0]const u8 {
        switch (self.internal) {
            .command => |interaction| {
                if (interaction.data == null) return null;
                const options = interaction.data.?.options orelse return null;

                for (options.array[0..@intCast(options.size)]) |opt| {
                    if (opt.focused) return std.mem.span(opt.value);
                }
            },
            .message => |interaction| {
                _ = interaction;
            },
        }
        return null;
    }

    pub fn respond(self: @This(), client: discord.Client, comptime format: []const u8, args: anytype) !void {
        var buf: [256]u8 = undefined;
        const content = try std.fmt.bufPrintSentinel(&buf, format, args, 0);
        switch (self.internal) {
            .command => |interaction| try interaction.respond(client, .{ .data = &.{ .content = content.ptr } }, null),
            .message => |interaction| try discord.Message.create(client, interaction.channel_id, .{ .content = content }),
        }
    }

    pub fn autocomplete(self: @This(), client: discord.Client, choices: []const AutocompleteChoice) !void {
        if (choices.len > AutocompleteChoice.max_count) return error.TooManyAutocompleteChoices;

        switch (self.internal) {
            .command => |interaction| try interaction.respond(client, .{
                .type = .APPLICATION_COMMAND_AUTOCOMPLETE_RESULT,
                .data = &.{ .choices = &.{
                    .array = @ptrCast(choices.ptr),
                    .size = @intCast(choices.len),
                    .realsize = @intCast(choices.len),
                } },
            }, null),
            .message => {},
        }
    }
};

pub fn call(client: discord.Client, command_name: [*:0]const u8, interaction: Interaction) void {
    callWithError(client, command_name, interaction) catch |err| {
        std.log.err("{t} when calling command {s}", .{ err, command_name });
        interaction.respond(client, "Error {t} when calling command {s} ", .{ err, command_name }) catch {};
    };
}

fn callWithError(client: discord.Client, command_name: [*:0]const u8, interaction: Interaction) !void {
    const command: @This() = for (commands) |command| {
        if (std.mem.eql(u8, std.mem.span(command_name), command.name)) break command;
    } else return error.CommandNotFound;

    switch (interaction.internal) {
        .command => switch (interaction.internal.command.type) {
            .APPLICATION_COMMAND => if (command.onExecute) |onExecute| {
                try onExecute(client, interaction);
                std.log.info("executed command '{s}' by {s}", .{ command.name, interaction.user.name });
            },
            .APPLICATION_COMMAND_AUTOCOMPLETE => if (command.onAutocomplete) |onAutocomplete| {
                try onAutocomplete(client, interaction);
                std.log.info("autocompleted command '{s}' by {s}", .{ command.name, interaction.user.name });
            },
            else => return error.InvalidInteractionType,
        },
        .message => if (command.onExecute) |onExecute| try onExecute(client, interaction),
    }
}
