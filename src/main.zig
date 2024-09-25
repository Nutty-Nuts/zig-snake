const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello, world!\n", .{});
    std.debug.print("{any}\n", .{@TypeOf('◼')});

    var code_bytes: [4]u8 = undefined;
    const unicode = try std.unicode.utf8Encode('◼', &code_bytes);

    std.debug.print("◼ {u}\n", .{unicode});
}
