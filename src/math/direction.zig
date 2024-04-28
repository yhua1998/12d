const std = @import("std");
const zmath = @import("zmath");

const sqrt = 0.70710678118654752440084436210485;
const sqrt2 = 1.4142135623730950488016887242097;

/// 方向
pub const Direction = enum(u8) {
    none = 0,

    n = 0b0000_0001,
    e = 0b0000_0100,
    s = 0b0000_0011,
    w = 0b0000_1100,

    se = 0b0000_0111,
    ne = 0b0000_0101,
    nw = 0b0000_1101,
    sw = 0b0000_1111,

    /// 根据位置偏移量计算方向
    pub fn find(comptime size: usize, vx: f32, vy: f32) Direction {
        return switch (size) {
            4 => {
                var d: u8 = 0;

                const absx = @abs(vx);
                const absy = @abs(vy);

                if (absy < absx * sqrt2) {
                    if (vx > 0) d = 0b0000_0100 else if (vx < 0) d = 0b0000_1100;
                } else {
                    if (vy > 0) d = 0b0000_0001 else if (vy < 0) d = 0b0000_0011;
                }

                return @as(Direction, @enumFromInt(d));
            },
            8 => {
                var d: u8 = 0;

                const absx = @abs(vx);
                const absy = @abs(vy);

                if (absy < absx * (sqrt2 + 1.0)) {
                    if (vx > 0) d = 0b0000_0100 else if (vx < 0) d = 0b0000_1100;
                }
                if (absy > absx * (sqrt2 - 1.0)) {
                    if (vy > 0) d = d | 0b0000_0001 else if (vy < 0) d = d | 0b0000_0011;
                }

                return @as(Direction, @enumFromInt(d));
            },
            else => @compileError("Direction size is unsupported!"),
        };
    }

    /// 将方向变量转换为方向
    pub fn write(n: bool, s: bool, e: bool, w: bool) Direction {
        var d: u8 = 0;
        if (w) {
            d = d | 0b0000_1100;
        }
        if (e) {
            d = d | 0b0000_0100;
        }
        if (n) {
            d = d | 0b0000_0001;
        }
        if (s) {
            d = d | 0b0000_0011;
        }
        return @as(Direction, @enumFromInt(d));
    }

    pub fn x(self: Direction) f32 {
        return @as(f32, @floatFromInt(@as(i8, @bitCast(@intFromEnum(self))) << 4 >> 6));
    }

    pub fn y(self: Direction) f32 {
        return @as(f32, @floatFromInt(@as(i8, @bitCast(@intFromEnum(self))) << 6 >> 6));
    }

    pub fn f32x4(self: Direction) zmath.F32x4 {
        return zmath.f32x4(self.x(), self.y(), 0, 0);
    }

    pub fn normalized(self: Direction) zmath.F32x4 {
        return switch (self) {
            .none => zmath.f32x4s(0),
            .s => zmath.f32x4(0, -1, 0, 0),
            .se => zmath.f32x4(sqrt, -sqrt, 0, 0),
            .e => zmath.f32x4(1, 0, 0, 0),
            .ne => zmath.f32x4(sqrt, sqrt, 0, 0),
            .n => zmath.f32x4(0, 1, 0, 0),
            .nw => zmath.f32x4(-sqrt, sqrt, 0, 0),
            .w => zmath.f32x4(-1, 0, 0, 0),
            .sw => zmath.f32x4(-sqrt, -sqrt, 0, 0),
        };
    }

    /// 方向翻转向西则返回true
    pub fn flippedHorizontally(self: Direction) bool {
        return switch (self) {
            .nw, .w, .sw => true,
            else => false,
        };
    }

    /// 方向翻转向北
    pub fn flippedVertically(self: Direction) bool {
        return switch (self) {
            .nw, .n, .ne => true,
            else => false,
        };
    }

    pub fn rotateCW(self: Direction) Direction {
        return switch (self) {
            .s => .sw,
            .se => .s,
            .e => .se,
            .ne => .e,
            .n => .ne,
            .nw => .n,
            .w => .nw,
            .sw => .w,
            .none => .none,
        };
    }

    pub fn rotateCCW(self: Direction) Direction {
        return switch (self) {
            .s => .se,
            .se => .e,
            .e => .ne,
            .ne => .n,
            .n => .nw,
            .nw => .w,
            .w => .sw,
            .sw => .s,
            .none => .none,
        };
    }

    pub fn fmt(self: Direction) [:0]const u8 {
        return switch (self) {
            .s => "south",
            .se => "southeast",
            .e => "east",
            .ne => "northeast",
            .n => "north",
            .nw => "northwest",
            .w => "west",
            .sw => "southwest",
            .none => "none",
        };
    }
};
