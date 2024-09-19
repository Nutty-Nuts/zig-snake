// File for program data structures
const constants = @import("constants.zig");
const std = @import("std");

pub const TermSize = struct { height: usize, width: usize };

pub const Collisions = struct {
    collision: [constants.game_height][constants.game_width]u8,
    pub fn init_collision(self: *Collisions) void {
        for (&self.collision) |*row| {
            for (row) |*col| {
                col.* = 0;
            }
        }
    }
    pub fn clear_collision(self: *Collisions) void {
        for (&self.collision) |*row| {
            for (row) |*col| {
                col.* = 0;
            }
        }
    }
    pub fn check_collision(self: *Collisions) bool {
        for (self.collision) |row| {
            for (row) |elem| {
                if (elem > 1) {
                    return true;
                }
            }
        }
        return false;
    }
    pub fn put_entity(self: *Collisions, x: usize, y: usize) void {
        self.collision[y][x] += 1;
    }
    pub fn debug(self: *Collisions) void {
        var x: usize = 0;
        var y: usize = 0;
        for (self.collision) |row| {
            y = 0;
            for (row) |elem| {
                if (elem == 1) {
                    std.debug.print("entity detected at x:{}, y:{}\n", .{ x, y });
                }
                if (elem > 1) {
                    std.debug.print("collision detected at x:{}, y:{}\n", .{ x, y });
                }
                y += 1;
            }
            x += 1;
        }
    }
};

pub const Renderer = struct {
    frame: [constants.game_height][constants.game_width]u8,
    pub fn init_frame(self: *Renderer) void {
        for (&self.frame) |*row| {
            for (row) |*col| {
                col.* = constants.blank;
            }
        }
    }
    pub fn clear_frame(self: *Renderer) void {
        for (&self.frame) |*row| {
            for (row) |*col| {
                col.* = constants.blank;
            }
        }
    }
    pub fn render_frame(self: *Renderer) void {
        for (&self.frame) |*row| {
            for (row) |*col| {
                std.debug.print("{c}", .{col.*});
            }
            std.debug.print("\n", .{});
        }
    }
    pub fn render_delay(self: *Renderer) void {
        _ = self;
        std.time.sleep((1 * constants.ns_per_s) / constants.fps);
    }
    pub fn put_pixel(self: *Renderer, char: u8, x: usize, y: usize) void {
        self.frame[y][x] = char;
    }
};

pub const Entity = struct {
    char: u8,
    x: isize,
    y: isize,
    x_velocity: isize,
    y_velocity: isize,
    pub fn flip_velocity_x(self: *Entity) void {
        self.x_velocity = self.x_velocity * (-1);
    }
    pub fn flip_velocity_y(self: *Entity) void {
        self.y_velocity = self.y_velocity * (-1);
    }
    pub fn move(self: *Entity) void {
        self.x = self.x + self.x_velocity * 2;
        self.y = self.y + self.y_velocity;

        if (self.x >= constants.game_width) {
            self.x = 0;
        }
        if (self.x < 0) {
            self.x = constants.game_width - 1;
        }

        if (self.y >= constants.game_height) {
            self.y = 0;
        }
        if (self.y < 0) {
            self.y = constants.game_height - 1;
        }
    }
    pub fn set_coordinates(self: *Entity, x: isize, y: isize) void {
        if (x >= constants.game_width) {
            return;
        }
        if (x < 0) {
            return;
        }
        if (y >= constants.game_height) {
            return;
        }
        if (y < 0) {
            return;
        }

        self.x = x;
        self.y = y;
    }
};
