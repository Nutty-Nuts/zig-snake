const std = @import("std");
const builtin = @import("builtin");

const constants = @import("constants.zig");
const data = @import("data.zig");
const ansi = @import("ansi.zig");

const allocator = std.heap.page_allocator;
const initer = 0;

var stdout: std.fs.File.Writer = undefined;
var stdin: std.fs.File.Reader = undefined;
var rand: std.rand.Random = undefined;
var term_size: data.TermSize = .{ .height = 0, .width = 0 };
var renderer: data.Renderer = .{ .frame = undefined };
var collision: data.Collisions = .{ .collision = undefined };

fn get_term_size(tty: std.posix.fd_t) !data.TermSize {
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

fn init_term_size() !void {
    term_size = try get_term_size(stdout.context.handle);
}

fn init_term() !void {
    try init_term_size();
    try ansi.start_screen_buf();
    try ansi.hide_cursor();
}

fn debug(frames: u32, list: std.ArrayListAligned(*data.Entity, null)) !void {
    if (constants.debug) {
        std.debug.print("[frames]\n", .{});
        std.debug.print("{}\n\n", .{frames});

        std.debug.print("[entities]\n", .{});
        for (list.items) |item| {
            std.debug.print("{any}\n", .{item});
        }

        std.debug.print("\n[collisions]\n", .{});
        collision.debug();
    }
}

pub fn main() !void {
    try init_term();
    renderer.init_frame();

    try ansi.refresh_screen();

    std.debug.print("Welcome to Snake Game!\n", .{});
    std.debug.print("By Nutty-Nuts\n\n", .{});

    std.debug.print("terminal info:\n", .{});
    std.debug.print("height: {}, width: {}\n", .{ term_size.height, term_size.width });

    std.time.sleep(2 * constants.ns_per_s);

    try ansi.refresh_screen();

    var timer: usize = 64;

    var h_moving_particle: data.Entity = .{ .char = '@', .x = 0, .y = 0, .x_velocity = 1, .y_velocity = 0 };
    var v_moving_particle: data.Entity = .{ .char = '@', .x = 4, .y = 0, .x_velocity = 0, .y_velocity = 1 };
    var static_particle: data.Entity = .{ .char = 'O', .x = 4, .y = 4, .x_velocity = 0, .y_velocity = 0 };

    var list = std.ArrayList(*data.Entity).init(allocator);

    try list.append(&static_particle);
    try list.append(&h_moving_particle);
    try list.append(&v_moving_particle);

    collision.init_collision();

    var frames: u32 = 0;

    while (timer > 0) : ({
        timer = timer - 1;
        frames = frames + 1;
        try debug(frames, list);
    }) {
        try ansi.refresh_screen();
        renderer.clear_frame();
        collision.clear_collision();

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
            collision.put_entity(@intCast(item.*.x), @intCast(item.*.y));
        }

        renderer.render(list);
    }
    try ansi.end_screen_buf();
    try ansi.show_cursor();
}
