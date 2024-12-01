const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const num_days = 1;
    const day: ?usize = b.option(usize, "ay", "Select day");
    const test_step = b.step("test", "Run unit tests");
    const run_step = b.step("run", "Run code");

    if (day) |n| {
        var steps = buildDay(b, n, target, optimize);

        test_step.dependOn(&steps.run_tests.step);
        run_step.dependOn(&steps.run_exe.step);

        if (b.args) |args| {
            steps.run_exe.addArgs(args);
        } else {
            steps.run_exe.addFileArg(b.path(b.fmt("inputs/{}", .{n})));
        }
    } else {
        for (1..(num_days + 1)) |n| {
            var steps = buildDay(b, n, target, optimize);

            test_step.dependOn(&steps.run_tests.step);
            run_step.dependOn(&steps.run_exe.step);

            steps.run_exe.addFileArg(b.path(b.fmt("inputs/{}", .{n})));
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
