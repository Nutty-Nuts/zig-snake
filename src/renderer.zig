const std = @import("std");
const config = @import("config.zig");
const constants = @import("constants.zig");

pub const Renderer = struct {
    frame: [config.gameHeight][config.gameWidth]u16,
    init: bool = false,
    pub fn init(self: *Renderer) void {
        for (&self.frame) |*row| {
            for (row) |*elem| {
                elem.* = constants.blank;
            }
        }
    }
    pub fn clear(self: *Renderer) void {
        for (&self.frame) |*row| {
            for (row) |*elem| {
                elem.* = constants.blank;
            }
        }
    }
    pub fn render(self: *Renderer) void {
        for (&self.frame) |*row| {
            for (row) |*elem| {
                std.debug.print("{s}", .{elem.*});
            }
        }
    }
    pub fn delay(self: *Renderer) void {
        _ = self;
        std.time.sleep((1 * constants.ns_per_s) / config.fps);
    }

    pub fn put(self: *Renderer) void {}
};
