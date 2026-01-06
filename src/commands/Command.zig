const discord = @import("discord");

name: [:0]const u8,
description: [:0]const u8,
onExecute: ?Execute = null,

pub const Execute = *const fn (client: discord.Client, interaction: *const discord.Interaction) anyerror!void;

pub const commands: []const @This() = &.{
    @import("globglogabgelab.zig").command,
};

pub const Enum = e: {
    const TagInt = usize;
    const field_names: [commands.len][]const u8 = undefined;
    const field_values: [commands.len]TagInt = undefined;
    for (commands, field_names, &field_values, 0..) |command, field_name, *field_value, i| {
        field_name = command.name;
        field_value.* = i;
    }
    break :e @Enum(TagInt, .exhaustive, field_names, &field_values);
};

pub fn enumToDescription(e: Enum) [:0]const u8 {
    _ = e;
}
