const std = @import("std");
const config = @import("config.zig");

pub const Renderer = struct {
    frame: [config.gameHeight][config.gameWidth]u16,
    init: bool = false,
    pub fn init_renderer(self: *Renderer) void {}
    pub fn clear(self: *Renderer) void {}
    pub fn render(self: *Renderer) void {}
    pub fn delay(self: *Renderer) void {}
};
