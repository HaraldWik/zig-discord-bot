const std = @import("std");
const discord = @import("discord");

const Command = @This();

name: [:0]const u8,
description: [:0]const u8,
onExecute: ?Execute = null,
onAutocomplete: ?Autocomplete = null,
options: []const discord.ApplicationCommand.Option = &.{},

pub const commands: []const @This() = &.{
    @import("help.zig").command,
    @import("globglogabgelab.zig").command,
    @import("profile.zig").command,
    @import("leaderboard.zig").command,
    @import("meow.zig").command,
};

pub const message_command_prefix = "!";
pub const message_command_autocomplete_identifier = "autocomplete";

pub const Execute = *const fn (client: discord.Client, interaction: Interaction) anyerror!void;
pub const Autocomplete = *const fn (client: discord.Client, interaction: Interaction) anyerror!void;
pub const AutocompleteChoice = extern struct {
    name: [*:0]const u8,
    value: [*:0]const u8,

    pub const max_count = 25;
};
pub const AutocompleteFocus = struct {
    name: []const u8,
    value: []const u8,
};

pub const Interaction = struct {
    id: u64,
    user: *discord.User,
    member: ?*discord.guild_member,
    channel_id: u64,
    guild_id: u64,
    application_id: u64,

    command: ?Command, // This can safely be unwrapped in command callbacks such as onExecute and onAutocomplete
    inner: Inner,

    pub const Inner = union(enum) {
        command: *const discord.Interaction,
        message: *const discord.Message,

        pub fn name(self: @This()) []const u8 {
            return switch (self) {
                .command => |inner| std.mem.span(inner.data.?.name),
                .message => |inner| name: {
                    const command_name: []const u8 = std.mem.span(inner.content[message_command_prefix.len..]);
                    const end = std.mem.indexOfScalar(u8, command_name, ' ') orelse command_name.len;
                    break :name command_name[0..end];
                },
            };
        }
    };

    pub const Type = enum {
        command,
        autocomplete,
    };

    pub fn fromInner(inner: Inner) Interaction {
        const command: ?Command = for (commands) |command| {
            if (std.mem.eql(u8, inner.name(), command.name)) break command;
        } else null;

        return switch (inner) {
            .command => |interaction| .{
                .command = command,
                .inner = inner,
                .id = interaction.id,
                .user = interaction.user orelse interaction.member.?.user,
                .member = interaction.member,
                .channel_id = interaction.channel_id,
                .guild_id = interaction.guild_id,
                .application_id = interaction.application_id,
            },
            .message => |interaction| .{
                .command = command,
                .inner = inner,
                .id = interaction.id,
                .user = interaction.author,
                .member = interaction.member,
                .channel_id = interaction.channel_id,
                .guild_id = interaction.guild_id,
                .application_id = interaction.application_id,
            },
        };
    }

    pub fn getContents(self: @This()) [:0]const u8 {
        return switch (self.inner) {
            .command => |inner| std.mem.span(inner.message.?.content[self.command.?.name.len..]),
            .message => |inner| std.mem.span(inner.content)[message_command_prefix.len + self.command.?.name.len ..],
        };
    }

    pub fn option(self: @This(), comptime name: @EnumLiteral()) ?[]const u8 {
        switch (self.inner) {
            .command => |inner| {
                if (inner.data == null) return null;
                const options = inner.data.?.options orelse return null;

                for (options.array[0..@intCast(options.size)]) |opt| {
                    if (std.mem.eql(u8, std.mem.span(opt.name), @tagName(name))) return std.mem.span(opt.value);
                }
            },
            .message => |inner| {
                const opt_name_index: usize = for (self.command.?.options, 0..) |opt, i| {
                    if (std.mem.eql(u8, std.mem.span(opt.name), @tagName(name))) break i;
                } else return null;
                {
                    var it = std.mem.splitScalar(u8, std.mem.span(inner.content[message_command_prefix.len + self.inner.name().len ..]), '"');
                    var i: usize = 0;
                    _ = it.next() orelse return null;
                    while (it.next()) |lexeme| : (i += 1) {
                        if (i > opt_name_index) return null;
                        if (i == opt_name_index) return lexeme;
                    }
                }
                {
                    var it = std.mem.splitScalar(u8, std.mem.span(inner.content[message_command_prefix.len + self.inner.name().len ..]), ' ');
                    var i: usize = 0;
                    _ = it.next() orelse return null;
                    while (it.next()) |lexeme| : (i += 1) {
                        if (i > opt_name_index) return null;
                        if (i == opt_name_index) return lexeme;
                    }
                }
                return null;
            },
        }
        return null;
    }

    pub fn focused(self: @This()) ?AutocompleteFocus { // TODO: fix
        switch (self.inner) {
            .command => |inner| {
                if (inner.data == null) return null;
                const options = inner.data.?.options orelse return null;

                for (options.array[0..@intCast(options.size)]) |opt| {
                    if (opt.focused) return .{ .name = std.mem.span(opt.name), .value = std.mem.span(opt.value) };
                }
            },
            .message => {
                var it = std.mem.splitScalar(u8, self.getContents(), ' ');
                var i: usize = 0;
                while (it.next()) |lexeme| : (i += 1) {
                    if (!std.mem.eql(u8, lexeme, message_command_autocomplete_identifier)) continue;

                    const opt = self.command.?.options[i - 1];
                    return .{
                        .name = std.mem.span(opt.name),
                        .value = "",
                    };
                }
            },
        }
        return null;
    }

    pub fn respond(self: @This(), client: discord.Client, comptime format: []const u8, args: anytype) !void {
        var buf: [256]u8 = undefined;
        const content = try std.fmt.bufPrintSentinel(&buf, format, args, 0);
        switch (self.inner) {
            .command => |inner| try inner.respond(client, .{
                .data = &.{
                    .content = content.ptr,
                },
            }, null),
            .message => |inner| try discord.Message.create(client, inner.channel_id, .{
                .content = content,
                .allowed_mentions = &.{
                    .users = &discord.snowflakes{},
                },
            }),
        }
    }

    pub fn autocomplete(self: @This(), client: discord.Client, choices: []const AutocompleteChoice) !void {
        if (choices.len > AutocompleteChoice.max_count) return error.TooManyAutocompleteChoices;

        switch (self.inner) {
            .command => |inner| try inner.respond(client, .{
                .type = .APPLICATION_COMMAND_AUTOCOMPLETE_RESULT,
                .data = &.{ .choices = &.{
                    .array = @ptrCast(choices.ptr),
                    .size = @intCast(choices.len),
                    .realsize = @intCast(choices.len),
                } },
            }, null),
            .message => |inner| {
                var fixed_writer_buffer: [4096]u8 = undefined;
                var fixed_writer: std.Io.Writer = .fixed(&fixed_writer_buffer);
                const writer = &fixed_writer;

                for (choices, 0..) |choice, i| {
                    try writer.print("{s}", .{choice.name});
                    const delimiter = if (i == choices.len - 1) " " else "**,** ";
                    try writer.writeAll(delimiter);
                }
                try writer.writeByte(0);

                try discord.Message.create(client, inner.channel_id, .{ .content = writer.buffer[0 .. writer.end - 1 :0].ptr });
            },
        }
    }
};

pub fn call(client: discord.Client, interaction: Interaction) void {
    const command_name = if (interaction.command) |command| command.name else interaction.inner.name();

    if (callWithError(client, interaction)) |interaction_type| {
        switch (interaction_type) {
            .command => std.log.info("executed command '{s}' by {s}", .{ command_name, interaction.user.name }),
            .autocomplete => std.log.info("autocompleted command '{s}' by {s}", .{ command_name, interaction.user.name }),
        }
    } else |err| {
        std.log.err("{t} command: '{s}' {s}", .{ err, command_name, interaction.user.name });
        interaction.respond(client, "Error {t} when calling command {s} ", .{ err, command_name }) catch {};
    }
}

fn callWithError(client: discord.Client, interaction: Interaction) !Interaction.Type {
    const command = interaction.command orelse return error.CommandNotFound;
    switch (interaction.inner) {
        .command => |inner| switch (inner.type) {
            .APPLICATION_COMMAND => if (command.onExecute) |onExecute| {
                try onExecute(client, interaction);
                return .command;
            },
            .APPLICATION_COMMAND_AUTOCOMPLETE => if (command.onAutocomplete) |onAutocomplete| {
                try onAutocomplete(client, interaction);
                return .autocomplete;
            },
            else => return error.InvalidInteractionType,
        },
        .message => {
            var it = std.mem.splitScalar(u8, interaction.getContents(), ' ');
            while (it.next()) |lexeme| {
                if (!std.mem.eql(u8, lexeme, message_command_autocomplete_identifier)) continue;
                if (command.onAutocomplete) |onAutocomplete| try onAutocomplete(client, interaction);
                return .autocomplete;
            }

            if (command.onExecute) |onExecute| try onExecute(client, interaction);
            return .command;
        },
    }
    unreachable;
}
