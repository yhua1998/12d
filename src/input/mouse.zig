const std = @import("std");
const core = @import("mach").core;

const Mods = core.KeyMods;
const MouseButton = core.MouseButton;

const Self = @This();

buttons: []Button,
position: [2]f32 = .{ 0.0, 0.0 },
previous_position: [2]f32 = .{ 0.0, 0.0 },
scroll_x: ?f32 = null,
scroll_y: ?f32 = null,

pub const Action = enum {
    primary,
    secondary,
};

pub const ButtonState = enum {
    release,
    press,
};

pub const Button = struct {
    button: MouseButton,
    mods: ?Mods = null,
    action: Action,
    state: bool = false,
    previous_state: bool = false,
    // 此四个变量不太明白具体含义
    pressed_tile: [2]i32 = .{ 0, 0 },
    released_tile: [2]i32 = .{ 0, 0 },
    pressed_mods: Mods = std.mem.zeroes(Mods),
    released_mods: Mods = std.mem.zeroes(Mods),

    pub fn pressed(self: Button) bool {
        // 先前为未按压，当前按压
        return (self.state == true and self.state != self.previous_state);
    }

    pub fn down(self: Button) bool {
        return self.state == true;
    }

    pub fn released(self: Button) bool {
        return (self.state == false and self.state != self.previous_state);
    }

    pub fn up(self: Button) bool {
        return self.state == false;
    }
};

pub fn initDefault(allocator: std.mem.Allocator) !Self {
    var buttons = std.ArrayList(Button).init(allocator);
    return .{ .buttons = try buttons.toOwnedSlice() };
}

/// 返回具有指定动作的按钮
pub fn button_with(self: *Self, action: Action) ?*Button {
    for (self.buttons) |*bt| {
        if (bt.action == action) return bt;
    }
    return null;
}

// pub fn tile(self: *Self) [2]i32 {
//     const world_position =
// }
