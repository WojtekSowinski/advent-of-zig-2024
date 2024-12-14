const std = @import("std");

const Vec2D = struct {
    x: isize,
    y: isize,

    const Self = @This();

    pub fn add(self: Self, other: Self) Self {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn turnRight(self: Self) Self {
        return .{ .x = -self.y, .y = self.x };
    }

    pub fn isInside(self: Self, x_bound: isize, y_bound: isize) bool {
        return self.x >= 0 and self.x < x_bound and self.y >= 0 and self.y < y_bound;
    }

    pub fn index(self: Self, grid: [][]u8) *u8 {
        const x: usize = @intCast(self.x);
        const y: usize = @intCast(self.y);
        return &grid[y][x];
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = std.process.args();
    _ = args.skip();
    const input_path = args.next().?;
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    const input = try input_file.readToEndAlloc(allocator, 1_000_000);
    defer allocator.free(input);

    var grid_buffer: [1000][]u8 = undefined;
    var grid: [][]u8 = &grid_buffer;
    var lines = std.mem.split(u8, input, "\n");
    var i: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) break;
        grid_buffer[i] = @constCast(line);
        i += 1;
    }
    grid.len = i;

    var location = outer: for (grid, 0..) |line, y| {
        for (line, 0..) |char, x| {
            if (char == '^') break :outer Vec2D{ .x = @intCast(x), .y = @intCast(y) };
        }
    } else unreachable;
    var direction = Vec2D{ .x = 0, .y = -1 };

    var visited: usize = 0;

    const y_bound: isize = @intCast(grid.len);
    const x_bound: isize = @intCast(grid[0].len);
    outer: while (true) {
        const currentChar = location.index(grid);
        if (currentChar.* != 'X') {
            visited += 1;
            currentChar.* = 'X';
        }
        var nextLocation = location.add(direction);
        if (!nextLocation.isInside(x_bound, y_bound)) break;
        while (nextLocation.index(grid).* == '#') {
            direction = direction.turnRight();
            nextLocation = location.add(direction);
            if (!nextLocation.isInside(x_bound, y_bound)) break :outer;
        }
        location = nextLocation;
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(
        "[DAY 6]\nFinal Map:\n{s}\nVisited Positions: {}\n",
        .{input, visited},
    );

    try bw.flush();
}
