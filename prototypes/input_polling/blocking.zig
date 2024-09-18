const std = @import("std");

pub fn main() !void {
    var stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    while (true) {
        try stdout.print("Press a key: ", .{});
        var buf: [1]u8 = undefined;
        _ = try stdin.readAll(buf[0..1]);
        try stdout.print("You pressed: {}\n", .{buf[0]});
    }
}
