const std = @import("std");
const _constants = @import("constants.zig");

var frame: [_constants.game_height][_constants.game_width]u8 = undefined;

pub fn init_frame() !void {
    for (&frame) |*row| {
        for (row) |*col| {
            col.* = _constants.blank;
        }
    }
}

pub fn clear_frame() !void {
    for (&frame) |*row| {
        for (row) |*col| {
            col.* = _constants.blank;
        }
    }
}

pub fn render_frame() !void {
    for (frame) |row| {
        for (row) |col| {
            std.debug.print("{c}", .{col});
        }
        std.debug.print("\n", .{});
    }
}

pub fn put_pixel(char: u8, x: usize, y: usize) !void {
    frame[y][x] = char;
}

pub fn render_delay() !void {
    std.time.sleep((1 * _constants.ns_per_s) / _constants.fps);
}
