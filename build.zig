const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const num_days = 6;
    const day: ?usize = b.option(usize, "ay", "Select day");
    const test_step = b.step("test", "Run unit tests");
    const run_step = b.step("run", "Run code");

    var days: [num_days]DaySteps = undefined;
    for (1..(num_days + 1)) |n| days[n - 1] = buildDay(b, n, target, optimize);

    if (day) |n| {
        const steps = &days[n - 1];
        if (b.args) |args| {
            steps.run_exe.addArgs(args);
        } else {
            steps.run_exe.addFileArg(b.path(b.fmt("inputs/{}", .{n})));
        }
        test_step.dependOn(&steps.run_tests.step);
        run_step.dependOn(&steps.run_exe.step);
    } else {
        for (1..(num_days + 1)) |n| {
            const steps = &days[n - 1];
            steps.run_exe.addFileArg(b.path(b.fmt("inputs/{}", .{n})));
            test_step.dependOn(&steps.run_tests.step);
            run_step.dependOn(&steps.run_exe.step);
        }
    }
}

const DaySteps = struct {
    run_exe: *std.Build.Step.Run,
    run_tests: *std.Build.Step.Run,
};

fn buildDay(
    b: *std.Build,
    n: usize,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) DaySteps {
    const main_source = b.path(b.fmt("src/day{}.zig", .{n}));

    const exe = b.addExecutable(.{
        .name = b.fmt("day{}", .{n}),
        .root_source_file = main_source,
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const exe_unit_tests = b.addTest(.{
        .root_source_file = main_source,
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(exe_unit_tests);

    return .{ .run_exe = run_cmd, .run_tests = run_unit_tests };
}
