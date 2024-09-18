const std = @import("std");
const builtin = @import("builtin");

const _constants = @import("constants.zig");
const _data = @import("data.zig");
const _ansi = @import("ansi.zig");
const _render = @import("render.zig");

var stdout: std.fs.File.Writer = undefined;
var stdin: std.fs.File.Reader = undefined;
var rand: std.rand.Random = undefined;
var term_size: _data.TermSize = .{ .height = 0, .width = 0 };

fn get_term_size(tty: std.posix.fd_t) !_data.TermSize {
    var win_size = std.c.winsize{ .ws_col = 0, .ws_row = 0, .ws_xpixel = 0, .ws_ypixel = 0 };

    const rv = std.c.ioctl(tty, _constants.TIOCGWINSZ, @intFromPtr(&win_size));
    const err = std.posix.errno(rv);

    if (rv >= 0) {
        return _data.TermSize{ .height = win_size.ws_row, .width = win_size.ws_col };
    } else {
        std.process.exit(0);
        return std.posix.unexpectedErrno(err);
    }
}

fn init_term_size() !void {
    term_size = try get_term_size(stdout.context.handle);
}

fn init_term() !void {
    try init_term_size();
}

var collision: [_constants.game_height][_constants.game_width]usize = undefined;

fn init_collision() !void {
    for (&collision) |*row| {
        for (row) |*elem| {
            elem.* = 0;
        }
    }
}

fn clear_collision() !void {
    for (&collision) |*row| {
        for (row) |*elem| {
            elem.* = 0;
        }
    }
}

fn put_entity(x: usize, y: usize) !void {
    collision[y][x] += 1;
}

fn check_collision_debug() !void {
    var x: usize = 0;
    var y: usize = 0;
    for (collision) |row| {
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

pub fn main() !void {
    try init_term();
    try _render.init_frame();

    try _ansi.start_screen_buf();
    try _ansi.hide_cursor();
    try _ansi.refresh_screen();

    std.debug.print("Welcome to Snake Game!\n", .{});
    std.debug.print("By Nutty-Nuts\n\n", .{});

    std.debug.print("terminal info:\n", .{});
    std.debug.print("height: {}, width: {}\n", .{ term_size.height, term_size.width });

    std.time.sleep(2 * _constants.ns_per_s);

    try _ansi.refresh_screen();

    var timer: usize = 64;

    var h_moving_particle: _data.Entity = .{ .char = '@', .x = 0, .y = 0, .x_velocity = 1, .y_velocity = 0 };
    var v_moving_particle: _data.Entity = .{ .char = '@', .x = 4, .y = 0, .x_velocity = 0, .y_velocity = 1 };
    var static_particle: _data.Entity = .{ .char = 'O', .x = 4, .y = 4, .x_velocity = 0, .y_velocity = 0 };

    const allocator = std.heap.page_allocator;
    var list = std.ArrayList(*_data.Entity).init(allocator);

    try list.append(&static_particle);
    try list.append(&h_moving_particle);
    try list.append(&v_moving_particle);

    try init_collision();

    var frames: u32 = 0;

    while (timer > 0) : ({
        timer = timer - 1;
        frames = frames + 1;
    }) {
        try _ansi.refresh_screen();
        try _render.clear_frame();
        try clear_collision();

        if (timer == 56) {
            h_moving_particle.flip_velocity_x();
        }
        if (timer == 40) {
            h_moving_particle.x_velocity = 0;
            h_moving_particle.y_velocity = 1;
        }
        if (timer == 24) {
            h_moving_particle.flip_velocity_y();
        }

        h_moving_particle.move();
        v_moving_particle.move();

        for (list.items) |item| {
            try _render.put_pixel(item.*.char, @intCast(item.*.x), @intCast(item.*.y));
            try put_entity(@intCast(item.*.x), @intCast(item.*.y));
        }

        try _render.render_frame();

        if (_constants.debug) {
            std.debug.print("[frames]\n", .{});
            std.debug.print("{}\n\n", .{frames});

            std.debug.print("[entities]\n", .{});
            for (list.items) |item| {
                std.debug.print("{any}\n", .{item});
            }

            std.debug.print("\n[collisions]\n", .{});
            try check_collision_debug();
        }

        try _render.render_delay();
    }
    try _ansi.end_screen_buf();
    try _ansi.show_cursor();
}
