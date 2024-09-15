const std = @import("std");
const builtin = @import("builtin");
const _constants = @import("constants.zig");
const _data = @import("data.zig");
const _ansi = @import("ansi.zig");

var stdout: std.fs.File.Writer = undefined;
var stdin: std.fs.File.Reader = undefined;
var rand: std.rand.Random = undefined;
var term_size: _data.TermSize = .{ .height = 0, .width = 0 };

fn getTermSize(tty: std.posix.fd_t) !_data.TermSize {
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

fn initTermSize() !void {
    term_size = try getTermSize(stdout.context.handle);
}

fn initTerm() !void {
    try initTermSize();
}

fn framerate_delay() !void {
    std.time.sleep((1 * _constants.ns_per_s) / _constants.fps);
}

fn put_at_coord(char: u8, x: u32, y: u32) !void {
    var i: u32 = 0;
    var j: u32 = 0;

    while (j < y) : (j = j + 1) {
        std.debug.print("\n", .{});
    }
    while (i < x) : (i = i + 1) {
        std.debug.print(" ", .{});
    }
    std.debug.print("{c}", .{char});
}

var frame = [8][8]u8{
    [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
};

fn clear_frame() !void {
    for (&frame) |*row| {
        for (row) |*col| {
            col.* = '#';
        }
    }
}

fn put_pixel(char: u8, x: usize, y: usize) !void {
    frame[y][x] = char;
}

fn render_frame() !void {
    for (frame) |row| {
        for (row) |col| {
            std.debug.print("{c}", .{col});
        }
        std.debug.print("\n", .{});
    }
}

pub fn main() !void {
    try initTerm();

    try _ansi.start_screen_buf();
    try _ansi.hide_cursor();
    try _ansi.refresh_screen();

    std.debug.print("Welcome to Snake Game!\n", .{});
    std.debug.print("By Nutty-Nuts\n\n", .{});

    std.debug.print("terminal info:\n", .{});
    std.debug.print("height: {}, width: {}\n", .{ term_size.height, term_size.width });

    // const word = "word";
    // const word: [5]u8 = [_]u8{ 'H', 'e', 'l', 'l', 'o' };

    // std.debug.print("{c}\n", .{word[0]});

    std.time.sleep(2 * _constants.ns_per_s);

    try _ansi.refresh_screen();

    // try put_at_coord('@', 4, 4);

    // var particle: _data.Entity = .{ .char = '@', .x = 0, .y = 0 };

    var particle_a: _data.Entity = .{ .char = '@', .x = 0, .y = 0 };
    var particle_b: _data.Entity = .{ .char = '@', .x = 0, .y = 7 };

    var timer: u32 = 32;

    while (timer > 0) : (timer = timer - 1) {
        try _ansi.refresh_screen();

        if (particle_a.x < 7) {
            particle_a.x = particle_a.x + 1;
        }
        if (particle_b.x > 0) {
            particle_b.x = particle_b.x - 1;
        }

        if (particle_a.y < 7) {
            particle_a.y = particle_a.y + 1;
        }
        if (particle_b.y > 0) {
            particle_b.y = particle_b.y - 1;
        }

        try clear_frame();

        try put_pixel(particle_a.char, particle_a.x, particle_a.y);
        try put_pixel(particle_b.char, particle_b.x, particle_b.y);

        try render_frame();
        try framerate_delay();
    }

    // while (particle.x < 16) : (particle.x = particle.x + 2) {
    //     try _ansi.refresh_screen();
    //     try put_at_coord(particle.char, particle.x, particle.y);
    //     try framerate_delay();
    // }
    // while (particle.y < 4) : (particle.y = particle.y + 1) {
    //     try _ansi.refresh_screen();
    //     try put_at_coord(particle.char, particle.x, particle.y);
    //     try framerate_delay();
    // }
    // while (particle.x > 0) : (particle.x = particle.x - 2) {
    //     try _ansi.refresh_screen();
    //     try put_at_coord(particle.char, particle.x, particle.y);
    //     try framerate_delay();
    // }
    // while (particle.y > 0) : (particle.y = particle.y - 1) {
    //     try _ansi.refresh_screen();
    //     try put_at_coord(particle.char, particle.x, particle.y);
    //     try framerate_delay();
    // }

    try _ansi.end_screen_buf();
    try _ansi.show_cursor();
}
