const std = @import("std");
const builtin = @import("builtin");
const constants = @import("constants.zig");
const data = @import("data.zig");

var stdout: std.fs.File.Writer = undefined;
var stdin: std.fs.File.Reader = undefined;
var rand: std.rand.Random = undefined;
var term_size: data.TermSize = .{ .height = 0, .width = 0 };

fn getTermSize(tty: std.posix.fd_t) !data.TermSize {
    var win_size = std.c.winsize{ .ws_col = 0, .ws_row = 0, .ws_xpixel = 0, .ws_ypixel = 0 };

    const rv = std.c.ioctl(tty, constants.TIOCGWINSZ, @intFromPtr(&win_size));
    const err = std.posix.errno(rv);

    if (rv >= 0) {
        return data.TermSize{ .height = win_size.ws_row, .width = win_size.ws_col };
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

fn refresh_screen() !void {
    std.debug.print("{s}\n", .{constants.screen_clear});
    std.debug.print("{s}\n", .{constants.cursor_home});
}

fn framerate_delay() !void {
    std.time.sleep((1 * constants.ns_per_s) / constants.fps);
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

pub fn main() !void {
    try initTerm();

    try refresh_screen();

    std.debug.print("Welcome to Snake Game!\n", .{});
    std.debug.print("By Nutty-Nuts\n\n", .{});

    std.debug.print("terminal info:\n", .{});
    std.debug.print("height: {}, width: {}\n", .{ term_size.height, term_size.width });

    std.time.sleep(2 * constants.ns_per_s);

    try refresh_screen();

    try put_at_coord('@', 4, 4);

    var particle: data.Entity = .{ .char = '@', .x = 0, .y = 0 };

    while (particle.x < 16) : (particle.x = particle.x + 2) {
        try refresh_screen();
        try put_at_coord(particle.char, particle.x, particle.y);
        try framerate_delay();
    }
    while (particle.y < 4) : (particle.y = particle.y + 1) {
        try refresh_screen();
        try put_at_coord(particle.char, particle.x, particle.y);
        try framerate_delay();
    }
    while (particle.x > 0) : (particle.x = particle.x - 2) {
        try refresh_screen();
        try put_at_coord(particle.char, particle.x, particle.y);
        try framerate_delay();
    }
    while (particle.y > 0) : (particle.y = particle.y - 1) {
        try refresh_screen();
        try put_at_coord(particle.char, particle.x, particle.y);
        try framerate_delay();
    }
}
