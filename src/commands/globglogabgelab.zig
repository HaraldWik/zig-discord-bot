const std = @import("std");
const Command = @import("Command.zig");
const discord = @import("discord");

pub const command: Command = .{
    .name = "globglogabgelab",
    .description = "The Globglogabgelab will sing you a banger from 2016!",
    .onExecute = onExecute,
};

pub fn onExecute(client: discord.Client, interaction: *const discord.Interaction) !void {
    var prng: std.Random.DefaultPrng = .init(interaction.id);
    const random = prng.random();

    const video_index = random.int(usize) % Video.vidoes.len;
    const video = Video.vidoes[video_index];

    var buf: [128]u8 = undefined;
    const content = try std.fmt.bufPrintSentinel(&buf, "{s} {s} [⠀](https://www.youtube.com/watch?v={s})", .{ video.name, video.description orelse "", video.url }, 0);

    try interaction.respond(client, .{ .data = &.{ .content = content } }, null);
}

pub const Video = struct {
    url: []const u8,
    name: []const u8,
    description: ?[]const u8 = null,

    const vidoes: []const @This() = &.{
        .{ .url = "hLljd8pfiFg", .name = "Official" },
        .{ .url = "cIwRQwAS_YY", .name = "Lil" },
        .{ .url = "7C5zM8CnZF0", .name = "XXX" },
        .{ .url = "2vhQBN0xJJ8", .name = "Havana" },
        .{ .url = "47ZSI7nPAqo", .name = "Stressed" },
        .{ .url = "xnl0iddwELA", .name = "Pumped up" },
        .{ .url = "geWmx4YnRZA", .name = "Gangnam style" },
        .{ .url = "ZSAypaq7log", .name = "Gods Plan" },
        .{ .url = "a-QpDm0A3Ng", .name = "Bad and Boujee" },
        .{ .url = "lCS3y1qn4C8", .name = "What is Love" },
        .{ .url = "DVQsKYPm7mA", .name = "Piano Man" },
        .{ .url = "slogfEswemE", .name = "I'm blue" },
        .{ .url = "-pQnurfQZPI", .name = "Believer" },
        .{ .url = "wSXIblva5No", .name = "Osaki" },
        .{ .url = "OT4MyqrWo6E", .name = "Darude - Sandstorm" },
        .{ .url = "_OFN2Uztp34", .name = "Schwabblestorm" },
        .{ .url = "WMemX2uKUNI", .name = "The Glob Man" },
        .{ .url = "7XBjuDkXJ60", .name = "Rap Glob" },
        .{ .url = "uQASsDVChTQ", .name = "Loves Books" },
        .{ .url = "FSAibrRAUjM", .name = "Glob On Me" },
        .{ .url = "nV-ypF0L6Xs", .name = "Ear Rape", .description = "EAR WARNING ⚠️" },
        .{ .url = "TtqMwwfhErQ", .name = "Globglogabgalab Busters" },
        .{ .url = "CaWT1ayLyB0", .name = "Chop Suey" },
        .{ .url = "okZNjPP1VQ4", .name = "PPAP" },
        .{ .url = "-XBaIpW--T4", .name = "wii" },
        .{ .url = "uPmNlnGNEqw", .name = "Tyrone" },
        .{ .url = "e5WwKh5Nuqo", .name = "Polkka" },
        .{ .url = "G_hsLsKJmMM", .name = "USA" },
        .{ .url = "3pDdF4WC6mw", .name = "The Fresh Prince" },
        .{ .url = "NqAFlFE-b98", .name = "In the house" },
        .{ .url = "YHxhHz0tBqA", .name = "Stronger" },
        .{ .url = "oVk0NP02zLs", .name = "Redbone" },
        .{ .url = "oS0kaazgJTQ", .name = "Tokyo Drift", .description = "🚗" },
        .{ .url = "GfgFuytAWGw", .name = "MF DOOM" },
        .{ .url = "vwyOoX7VGTA", .name = "Crab Rave" },
        .{ .url = "A9cVvHv8j2o", .name = "GTA San Andreas" },
        .{ .url = "TO5xjH3wgpc", .name = "Zeze" },
        .{ .url = "bfBjUUWvaHg", .name = "Thug" },
        .{ .url = "LifQbgwfF5M", .name = "x10000000 speed" },
        .{ .url = "zUYJJ5wZulY", .name = "But I'm blue" },
        .{ .url = "M9V2l5KDMGY", .name = "Amazon" },
        .{ .url = "Hh-soLTb2uo", .name = "Wrong Notes" },
        .{ .url = "nmjHp_EkR9U", .name = "360" },
        .{ .url = "O5QAJQzeYas", .name = "Minecraft" },
        .{ .url = "dDTKAwikm94", .name = "Ｇｌｏｂｇｌｏｇａｂｇｅｌａｂ" },
        .{ .url = "9PT4UnsUvNw", .name = "Africa" },
        .{ .url = "rCm-R4nZM1s", .name = "Likes To Party" },
        .{ .url = "OvVWcb8KhPs", .name = "All Star" },
        .{ .url = "bUEBTr4cImY", .name = "Wrong Singing" },
        .{ .url = "89c4Y59z2rc", .name = "Faster and faster" },
        .{ .url = "lWO8TLqAwNU", .name = "Drunk" },
        .{ .url = "eHN3rbUWENI", .name = "Vocoded" },
        .{ .url = "CVWE9BPo0g0", .name = "Swedish", .description = "🇸🇪" },
        .{ .url = "0RxNKzLFxNY", .name = "Polish", .description = "🇵🇱" },
        .{ .url = "nxdTMhJa_rw", .name = "Arabic", .description = "🇸🇦" },
        .{ .url = "ostAWWuazsc", .name = "bstchld", .description = "Sigma" },
        .{ .url = "vel-CyHrvb4", .name = "Strawinski" },
        .{ .url = "yNOlOqLSAwk", .name = "Walter" },
        .{ .url = "y81WZvnHTt8", .name = "The Creator", .description = "This man ruined Lucas's life" },
        .{ .url = "YeemJlrNx2Q", .name = "Mark", .description = "Secretly a globglogebgelab" },
        .{ .url = "zISYDnXs5QI", .name = "Globzilla" },
        .{ .url = "U19kFq-zxzU", .name = "GMod" },
        .{ .url = "X5MUf95qzGI", .name = "Freaky" },
        .{ .url = "oxqCKsUiIWg", .name = "Instrumental" },
        .{ .url = "h6EuSlzO4m0", .name = "Ends it all" },
        .{ .url = "aTtnRjRJstc", .name = "Spiderman" },
    };
};
