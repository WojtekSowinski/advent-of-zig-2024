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

    var reports = try std.ArrayList(std.ArrayList(i8)).initCapacity(allocator, 1000);

    var splitter = std.mem.split(u8, input, "\n");

    var safe_reports: usize = 0;

    while (splitter.next()) |line| {
        if (line.len == 0) break;
        var levels = std.mem.split(u8, line, " ");
        var report = std.ArrayList(i8).init(allocator);
        try reports.append(report);
        while (levels.next()) |level| {
            const lvl = try std.fmt.parseInt(i8, level, 10);
            try report.append(lvl);
        }
        if (isSafe(report.items)) safe_reports += 1;
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("[DAY 2]\nSafe Reports: {}\n", .{safe_reports});

    try bw.flush();
}

fn isSafeWithNoDampener(report: []const i8) bool {
    if (report.len <= 1) return true;

    const sign = if (report[0] == report[1]) return false else std.math.sign(report[0] - report[1]);

    var i: usize = 0;
    while (i < report.len - 1) {
        if (!checkDiff(sign, report[i], report[i + 1])) return false;
        i += 1;
    }
    return true;
}

fn isSafe(report: []const i8) bool {
    var i: usize = 0;
    while (i < report.len) : (i+=1) {
        if (isSafeWithItemRemoved(report, i)) return true;
    }
    return false;
}

fn isSafeWithItemRemoved(report: []const i8, removed: usize) bool {
    if (report.len <= 2) return true;
    if (removed == 0) return isSafeWithNoDampener(report[1..]);
    if (removed == report.len - 1) return isSafeWithNoDampener(report[0 .. report.len - 1]);

    const secondIndex: usize = if (removed == 1) 2 else 1;
    const sign = if (report[0] == report[secondIndex])
        return false
    else
        std.math.sign(report[0] - report[secondIndex]);

    var i: usize = 0;
    while (i < report.len - 1) : (i += 1) {
        if (i == removed) continue;
        if (i + 1 == removed) {
            if (checkDiff(sign, report[i], report[i + 2])) continue else return false;
        }
        if (!checkDiff(sign, report[i], report[i + 1])) return false;
    }
    return true;
}

fn checkDiff(sign: i8, x: i8, y: i8) bool {
    const abs_diff: i8 = sign * (x - y);
    return abs_diff > 0 and abs_diff <= 3;
}
