const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const maxFileSize = 1_000_000;

    var args = std.process.args();
    _ = args.skip();
    const input_path = args.next().?;
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    const input = try input_file.readToEndAlloc(allocator, maxFileSize);

    var splitter = std.mem.split(u8, input, "\n");

    var lineList = try std.ArrayList([]const u8).initCapacity(allocator, 1000);
    while (splitter.next()) |line| if (line.len >= 4) try lineList.append(line);
    const lines = lineList.items;

    var countPart1: usize = 0;
    for (lines, 0..) |line, y| {
        for (line, 0..) |char, x| {
            if (char == 'X') countPart1 += lookForMAS(lines, x, y);
        }
    }

    var countPart2: usize = 0;
    for (lines[1 .. lines.len - 1], 1..) |line, y| {
        for (line[1 .. line.len - 1], 1..) |char, x| {
            if (char == 'A' and checkForX_MAS(lines, x, y)) countPart2 += 1;
        }
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(
        "[DAY 4]\nXMAS's Found: {}\nX-MAS's Found: {}\n",
        .{ countPart1, countPart2 },
    );

    try bw.flush();
}

fn lookForMAS(wordSearch: [][]const u8, x: usize, y: usize) usize {
    var count: usize = 0;
    var yDirection: isize = -1;
    while (yDirection < 2) : (yDirection += 1) {
        var xDirection: isize = -1;
        while (xDirection < 2) : (xDirection += 1) {
            count += lookInDirection(
                wordSearch,
                @intCast(x),
                @intCast(y),
                xDirection,
                yDirection,
            );
        }
    }
    return count;
}

fn strEq(str1: []const u8, str2: []const u8) bool {
    return std.mem.eql(u8, str1, str2);
}

fn lookInDirection(
    wordSearch: [][]const u8,
    x: isize,
    y: isize,
    xDirection: isize,
    yDirection: isize,
) usize {
    if (xDirection < 0 and x < 3) return 0;
    if (xDirection > 0 and x >= wordSearch[@intCast(y)].len - 3) return 0;
    if (yDirection < 0 and y < 3) return 0;
    if (yDirection > 0 and y >= wordSearch.len - 3) return 0;
    const letters = [_]u8{
        wordSearch[@intCast(y + yDirection)][@intCast(x + xDirection)],
        wordSearch[@intCast(y + 2 * yDirection)][@intCast(x + 2 * xDirection)],
        wordSearch[@intCast(y + 3 * yDirection)][@intCast(x + 3 * xDirection)],
    };
    if (strEq(&letters, "MAS")) return 1;
    return 0;
}

fn checkForX_MAS(wordSearch: [][]const u8, x: usize, y: usize) bool {
    const diagonal1 = [_]u8{ wordSearch[y - 1][x - 1], wordSearch[y + 1][x + 1] };
    const diagonal2 = [_]u8{ wordSearch[y + 1][x - 1], wordSearch[y - 1][x + 1] };

    return (strEq(&diagonal1, "MS") or strEq(&diagonal1, "SM")) and (strEq(&diagonal2, "MS") or strEq(&diagonal2, "SM"));
}
