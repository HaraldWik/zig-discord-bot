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

    const exe = b.addExecutable(.{
        .name = "bot",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "discord", .module = discord },
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

pub fn addCSourceFilesRecursive(b: *std.Build, module: *std.Build.Module, path: []const u8) !void {
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |file| {
        const new_path = try std.fs.path.join(b.allocator, &.{ path, file.name });
        defer b.allocator.free(new_path);
        std.debug.print("{s}\n", .{new_path});
        switch (file.kind) {
            .file => if (std.mem.endsWith(u8, file.name, ".c")) module.addCSourceFile(.{ .file = .{ .cwd_relative = new_path } }),
            .directory, .sym_link => try addCSourceFilesRecursive(b, module, new_path),
            else => {},
        }
    }
}
