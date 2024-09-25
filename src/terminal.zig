const std = @import("std");
const constants = @import("constants.zig");

pub fn refresh() void {
    std.debug.print("{s}", .{constants.screen_clear});
    std.debug.print("{s}", .{constants.cursor_home});
}

pub fn start_screen_buf() void {
    std.debug.print("{s}", .{constants.start_screen_buf});
}

pub fn end_screen_buf() void {
    std.debug.print("{s}", .{constants.end_screen_buf});
}

pub fn hide_cursor() void {
    std.debug.print("{s}", .{constants.cursor_hide});
}

pub fn show_cursor() void {
    std.debug.print("{s}", .{constants.cursor_show});
}
