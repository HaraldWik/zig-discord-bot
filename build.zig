const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const concord = b.dependency("concord", .{});

    var make = concord.builder.addSystemCommand(&.{ "make", "-s" });
    make.cwd = concord.path(".");

    const discord = b.createModule(.{
        .root_source_file = b.path("src/discord.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    discord.addLibraryPath(concord.path("lib"));
    discord.linkSystemLibrary("discord", .{ .needed = true });
    discord.linkSystemLibrary("curl", .{ .needed = true });

    const discord_header = b.addTranslateC(.{
        .root_source_file = concord.path("include/discord.h"),
        .target = target,
        .optimize = optimize,
    });
    discord_header.addIncludePath(concord.path("."));
    discord_header.addIncludePath(concord.path("core"));

    const exe = b.addExecutable(.{
        .name = "bot",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "discord", .module = discord },
                .{ .name = "concord", .module = discord_header.createModule() },
            },
        }),
    });

    exe.step.dependOn(&make.step);

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
}
