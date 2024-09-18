const std = @import("std");
const posix = std.os.linux;

// Enable raw mode for the terminal using the file descriptor
fn enableRawMode(fd: i32) !void {
    var termios = try posix.tcgetattr(fd);
    termios.lflag &= ~posix.ICANON; // Disable canonical mode (input processed immediately)
    termios.lflag &= ~posix.ECHO; // Disable echo (don't display typed characters)
    try posix.tcsetattr(fd, posix.TCSANOW, termios);
}

// Disable raw mode and restore the terminal settings
fn disableRawMode(fd: i32) !void {
    var termios = try posix.tcgetattr(fd);
    termios.lflag |= posix.ICANON; // Re-enable canonical mode
    termios.lflag |= posix.ECHO; // Re-enable echo
    try posix.tcsetattr(fd, posix.TCSANOW, termios);
}

// Check if there is input available using select() for non-blocking polling
fn isInputAvailable(fd: i32) bool {
    var readfds: posix.FdSet = undefined;
    posix.FD_ZERO(&readfds);
    posix.FD_SET(fd, &readfds);

    var timeout: posix.TimeVal = undefined;
    timeout.tv_sec = 0;
    timeout.tv_usec = 0; // Non-blocking, instant return

    const result = posix.select(fd + 1, &readfds, null, null, &timeout);
    return result > 0;
}

// Read a single key from stdin
fn readKey() u8 {
    var buf: [1]u8 = undefined;
    std.io.getStdIn().reader().readAll(buf[0..1]) catch return 0;
    return buf[0];
}

pub fn main() !void {
    const stdin_fd = std.io.getStdIn().handle;
    const stdout = std.io.getStdOut();

    // Ensure we disable raw mode when the program exits
    defer disableRawMode(stdin_fd) catch {};

    // Enable raw mode to get immediate, non-blocking input
    try enableRawMode(stdin_fd);

    var direction: u8 = 'r'; // Initial direction (right)

    // Game loop
    while (true) {
        // Poll for input without blocking
        if (isInputAvailable(stdin_fd)) {
            const key = readKey(stdin_fd);
            switch (key) {
                'w' => direction = 'u', // up
                'a' => direction = 'l', // left
                's' => direction = 'd', // down
                'd' => direction = 'r', // right
                'q' => break, // quit the game
                else => {},
            }
        }

        // Example: update snake movement (this is the game loop logic)
        try stdout.writer().print("Snake moving {}\n", .{direction});

        // Sleep for a bit to control game speed (snake speed)
        std.time.sleep(200 * std.time.millisecond);
    }
}
