// File for program data structures
const _constants = @import("constants.zig");
const std = @import("std");

pub const TermSize = struct { height: usize, width: usize };

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

        if (self.x >= _constants.game_width) {
            self.x = 0;
        }
        if (self.x < 0) {
            self.x = _constants.game_width - 1;
        }

        if (self.y >= _constants.game_height) {
            self.y = 0;
        }
        if (self.y < 0) {
            self.y = _constants.game_height - 1;
        }
    }
    pub fn set_coordinates(self: *Entity, x: isize, y: isize) void {
        if (x >= _constants.game_width) {
            return;
        }
        if (x < 0) {
            return;
        }
        if (y >= _constants.game_height) {
            return;
        }
        if (y < 0) {
            return;
        }

        self.x = x;
        self.y = y;
    }
};

// pub const StaticEntity = struct { char: u8, x: usize, y: usize };
