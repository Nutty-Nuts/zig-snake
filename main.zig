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
    var v_moving_particle: _data.Entity = .{ .char = '@', .x = 0, .y = 0, .x_velocity = 0, .y_velocity = 1 };
    const static_particle: _data.StaticEntity = .{ .char = 'O', .x = 4, .y = 4 };

    while (timer > 0) : (timer = timer - 1) {
        try _ansi.refresh_screen();
        try _render.clear_frame();

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

        try _render.put_pixel(h_moving_particle.char, @intCast(h_moving_particle.x), @intCast(h_moving_particle.y));
        try _render.put_pixel(v_moving_particle.char, @intCast(v_moving_particle.x), @intCast(v_moving_particle.y));
        try _render.put_pixel(static_particle.char, static_particle.x, static_particle.y);

        try _render.render_frame();
        try _render.render_delay();
    }
    //     var particle_a: _data.Entity = .{ .char = '@', .x = 0, .y = 0 };
    //     var particle_b: _data.Entity = .{ .char = '@', .x = 0, .y = 7 };

    //     var timer: u32 = 32;

    //     while (timer > 0) : (timer = timer - 1) {
    //         try _ansi.refresh_screen();

    //         if (particle_a.x < 7) {
    //             particle_a.x = particle_a.x + 1;
    //         }
    //         if (particle_b.x > 0) {
    //             particle_b.x = particle_b.x - 1;
    //         }

    //         if (particle_a.y < 7) {
    //             particle_a.y = particle_a.y + 1;
    //         }
    //         if (particle_b.y > 0) {
    //             particle_b.y = particle_b.y - 1;
    //         }

    //         try _render.clear_frame();

    //         try _render.put_pixel(particle_a.char, particle_a.x, particle_a.y);
    //         try _render.put_pixel(particle_b.char, particle_b.x, particle_b.y);

    //         try _render.render_frame();
    //         try _render.render_delay();
    //     }

    try _ansi.end_screen_buf();
    try _ansi.show_cursor();
}
