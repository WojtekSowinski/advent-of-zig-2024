const std = @import("std");

const Rule = struct { before: u8, after: u8 };

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

    var lines = std.mem.split(u8, input, "\n");

    var rules = try std.ArrayList(Rule).initCapacity(allocator, 1000);
    while (lines.next()) |line| {
        if (line.len == 0) break;
        var line_split = std.mem.split(u8, line, "|");
        const left_int = line_split.next().?;
        const right_int = line_split.next().?;
        try rules.append(.{
            .before = try std.fmt.parseInt(u8, left_int, 10),
            .after = try std.fmt.parseInt(u8, right_int, 10),
        });
    }

    var updates = try std.ArrayList(std.ArrayList(u8)).initCapacity(allocator, 500);
    while (lines.next()) |line| {
        if (line.len == 0) break;
        var update = try std.ArrayList(u8).initCapacity(allocator, 8);
        var line_split = std.mem.split(u8, line, ",");
        while (line_split.next()) |number| {
            try update.append(try std.fmt.parseInt(u8, number, 10));
        }
        try updates.append(update);
    }

    var correct_middle_numbers: usize = 0;
    var fixed_middle_numbers: usize = 0;
    var i: usize = 0;
    while (i < updates.items.len) : (i+=1) {
        const update = (updates.items[i].items);
        if (isCorrect(update, rules.items)) {
            correct_middle_numbers += middle(update);
        } else {
            fix(update, rules.items);
            fixed_middle_numbers += middle(update);
        }
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(
        \\[DAY 1]
        \\Sum of middle numbers in correct updates: {}
        \\Sum of middle numbers in fixed updates: {}
    ,
        .{ correct_middle_numbers, fixed_middle_numbers },
    );

    try bw.flush();
}

fn isCorrect(update: []u8, rules: []Rule) bool {
    return std.sort.isSorted(u8, update, rules, isBefore);
}


fn isBefore(rules: []Rule, x: u8, y: u8) bool {
    const target_rule = Rule{.before = x, .after = y};
    for (rules) |rule| {
        if (std.meta.eql(rule, target_rule)) return true;
    }
    return false;
}

fn fix(update: []u8, rules: []Rule) void {
    std.mem.sort(u8, update, rules, isBefore);
}

fn middle(update: []u8) u8 {
    if (update.len % 2 == 0) std.debug.panic("Update has no middle number.", .{});
    return update[update.len / 2];
}
