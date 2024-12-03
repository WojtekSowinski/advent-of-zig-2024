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
    var input: []const u8 = try input_file.readToEndAlloc(allocator, 1_000_000);

    var total: usize = 0;

    while (input.len > 0) {
        while (!match(&input, 'm')) _ = advance(&input) or break;
        _ = match(&input, 'u') or continue;
        _ = match(&input, 'l') or continue;
        _ = match(&input, '(') or continue;
        
        var split = span(input, isDigit);
        const left = std.fmt.parseInt(usize, split.first, 10) catch continue;
        input = split.second;

        _ = match(&input, ',') or continue;

        split = span(input, isDigit);
        const right = std.fmt.parseInt(usize, split.first, 10) catch continue;
        input = split.second;

        _ = match(&input, ')') or continue;

        total += left * right;
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Total: {}\n", .{total});

    try bw.flush();
}

fn isDigit(char: u8) bool {
    return '0' <= char and char <= '9';
}

const SplitString = struct {first: []const u8, second: []const u8};

fn span(str: []const u8, p: fn(u8) bool) SplitString {
    var i: usize = 0;
    while (i < str.len and p(str[i])) i+=1;
    return SplitString{.first = str[0..i], .second = str[i..],};
}

fn advance(str: *[]const u8) bool {
    if (str.len == 0) return false;
    str.* = str.*[1..];
    return true;
}

inline fn match(str: *[]const u8, expected: u8) bool {
    return str.len > 0 and str.*[0] == expected and advance(str);
}
