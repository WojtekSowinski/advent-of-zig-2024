const std = @import("std");

var total: usize = 0;
var enabled = true;

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

    while (input.len > 0) {
        if (enabled) {
            _ = parseMul(input) or parseDont(input);
        } else {
            _ = parseDo(input);
        }
        _ = advance(&input);
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Total: {}\n", .{total});

    try bw.flush();
}

fn parseMul(input: []const u8) bool {
    var code = input;

    for ("mul(") |c| {
        _ = match(&code, c) or return false;
    }

    var split = span(code, isDigit);
    const left = std.fmt.parseInt(usize, split.first, 10) catch return false;
    code = split.second;

    _ = match(&code, ',') or return false;

    split = span(code, isDigit);
    const right = std.fmt.parseInt(usize, split.first, 10) catch return false;
    code = split.second;

    _ = match(&code, ')') or return false;

    total += left * right;
    return true;
}

fn parseDo(input: []const u8) bool {
    var code = input;
    for ("do()") |c| {
        _ = match(&code, c) or return false;
    }
    enabled = true;
    return true;
}

fn parseDont(input: []const u8) bool {
    var code = input;
    for ("don't()") |c| {
        _ = match(&code, c) or return false;
    }
    enabled = false;
    return true;
}

fn isDigit(char: u8) bool {
    return '0' <= char and char <= '9';
}

const SplitString = struct { first: []const u8, second: []const u8 };

fn span(str: []const u8, p: fn (u8) bool) SplitString {
    var i: usize = 0;
    while (i < str.len and p(str[i])) i += 1;
    return SplitString{
        .first = str[0..i],
        .second = str[i..],
    };
}

fn advance(str: *[]const u8) bool {
    if (str.len == 0) return false;
    str.* = str.*[1..];
    return true;
}

inline fn match(str: *[]const u8, expected: u8) bool {
    return str.len > 0 and str.*[0] == expected and advance(str);
}
