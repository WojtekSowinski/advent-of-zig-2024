const std = @import("std");

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

    var left = try std.ArrayList(usize).initCapacity(allocator, 1000);
    var right = try std.ArrayList(usize).initCapacity(allocator, 1000);

    var splitter = std.mem.split(u8, input, "\n");

    while (splitter.next()) |line| {
        if (line.len == 0) break;
        var line_split = std.mem.split(u8, line, "   ");
        const left_int = line_split.next().?;
        const right_int = line_split.next().?;
        try left.append(try std.fmt.parseInt(usize, left_int, 10));
        try right.append(try std.fmt.parseInt(usize, right_int, 10));
    }

    std.mem.sort(usize, left.items, {}, comptime std.sort.asc(usize));
    std.mem.sort(usize, right.items, {}, comptime std.sort.asc(usize));

    var distance: usize = 0;
    for (left.items, right.items) |l, r| {
        distance += @max(l, r) - @min(l, r);
    }

    var similarity: usize = 0;
    for (left.items) |item| {
        similarity += item * (std.mem.count(usize, right.items, &[_]usize{item}));
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Distance: {}\nSimilarity Score: {}\n", .{distance, similarity});

    try bw.flush();
}
