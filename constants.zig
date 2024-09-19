// File for program constants
const std = @import("std");

pub const esc = "\x1B";
pub const csi = esc ++ "[";

pub const cursor_show = csi ++ "?25h";
pub const cursor_hide = csi ++ "?25l";
pub const cursor_home = csi ++ "1;1H";

pub const screen_clear = csi ++ "2J";
pub const screen_buf_on = csi ++ "?1049h";
pub const screen_buf_off = csi ++ "?1049l";

pub const nl = "\n";
pub const sep = "▏";

pub const TIOCGWINSZ = std.c.T.IOCGWINSZ;

pub const ns_per_us: u64 = 1000;
pub const ns_per_ms: u64 = 1000 * ns_per_us;
pub const ns_per_s: u64 = 1000 * ns_per_ms;

pub const fps: u32 = 6;

pub const game_height: u32 = 8;
pub const game_width: u32 = 16;

pub const blank: u8 = ' ';
pub const debug: bool = true;
