const std = @import("std");
const core = @import("mach").core;

const input = @import("input/input.zig");

pub const App = @This();

pub const name = "sunday";
pub var window_size: [2]f32 = undefined;
pub var framebuffer_size: [2]f32 = undefined;
pub var content_scale: [2]f32 = undefined;
pub var state: *GameState = undefined;

pub var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub const GameState = struct {
    allocator: std.mem.Allocator = undefined,
    root_path: [:0]const u8 = undefined,
    mouse: input.Mouse = undefined,
};

pub fn init(_: *App) !void {
    const allocator = gpa.allocator();

    var buffer: [1024]u8 = undefined;
    const root_path = std.fs.selfExeDirPath(buffer[0..]) catch ".";

    try core.init(.{
        .title = name,
        .size = .{
            .width = 1280,
            .height = 720,
        },
        .power_preference = .high_performance,
    });

    const descriptor = core.descriptor;
    const size = core.size();
    window_size = .{ @floatFromInt(size.width), @floatFromInt(size.height) };
    framebuffer_size = .{ @floatFromInt(descriptor.width), @floatFromInt(descriptor.height) };
    content_scale = .{
        framebuffer_size[0] / window_size[0],
        framebuffer_size[1] / window_size[1],
    };
    state = try allocator.create(GameState);
    state.* = .{ .root_path = try allocator.dupeZ(u8, root_path) };

    state.allocator = allocator;
    state.mouse = try input.Mouse.initDefault(allocator);
}

pub fn update(_: *App) !bool {
    var iter = core.pollEvents();

    while (iter.next()) |event| {
        switch (event) {
            .close => {
                return true;
            },
            else => {},
        }
    }

    return false;
}

pub fn deinit(_: *App) void {
    core.deinit();
}
