const std = @import("std");
const builtin = @import("builtin");

const mach = @import("mach");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zstbi = b.dependency("zstbi", .{ .target = target, .optimize = optimize });
    const zflecs = b.dependency("zflecs", .{ .target = target, .optimize = optimize });
    const zmath = b.dependency("zmath", .{ .target = target, .optimize = optimize });

    const mach_dep = b.dependency("mach", .{
        .target = target,
        .optimize = optimize,
    });

    const zig_imgui_dep = b.dependency("zig_imgui", .{});

    const imgui_module = b.addModule("zig-imgui", .{
        .root_source_file = zig_imgui_dep.path("src/imgui.zig"),
        .imports = &.{
            .{ .name = "mach", .module = mach_dep.module("mach") },
        },
    });

    const app = try mach.CoreApp.init(b, mach_dep.builder, .{
        .name = "aftersun",
        .src = "src/sunday.zig",
        .target = target,
        .deps = &.{
            .{ .name = "zstbi", .module = zstbi.module("root") },
            .{ .name = "zmath", .module = zmath.module("root") },
            .{ .name = "zflecs", .module = zflecs.module("root") },
            .{ .name = "zig-imgui", .module = imgui_module },
        },
        .optimize = optimize,
    });

    const run_step = b.step("run", "Run aftersun");
    run_step.dependOn(&app.run.step);

    app.compile.root_module.addImport("zstbi", zstbi.module("root"));
    app.compile.root_module.addImport("zmath", zmath.module("root"));
    app.compile.root_module.addImport("zflecs", zflecs.module("root"));
    app.compile.root_module.addImport("zig-imgui", imgui_module);

    app.compile.linkLibrary(zstbi.artifact("zstbi"));
    app.compile.linkLibrary(zflecs.artifact("flecs"));
    app.compile.linkLibrary(zig_imgui_dep.artifact("imgui"));
}
