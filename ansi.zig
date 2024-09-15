const std = @import("std");
const constants = @import("constants.zig");

pub fn refresh_screen() !void {
    std.debug.print("{s}\n", .{constants.screen_clear});
    std.debug.print("{s}\n", .{constants.cursor_home});
}

pub fn start_screen_buf() !void {
    std.debug.print("{s}\n", .{constants.screen_buf_on});
}

pub fn end_screen_buf() !void {
    std.debug.print("{s}\n", .{constants.screen_buf_off});
}

pub fn hide_cursor() !void {
    std.debug.print("{s}\n", .{constants.cursor_hide});
}

pub fn show_cursor() !void {
    std.debug.print("{s}\n", .{constants.cursor_show});
}
