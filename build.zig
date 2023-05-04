const std = @import("std");
const Build = std.Build;
const Mode = std.builtin.OptimizeMode;

pub fn build(b: *Build) void {

    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const optimize = b.standardOptimizeOption(.{});

    // Make binding Module
    const binding = b.createModule(.{
        .source_file = .{ .path = "generated/binding.zig" },
    });

    // Call cargo build
    const rustlib = cargo(b, optimize);

    const exe = b.addExecutable(.{
        .name = "zFFI",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/main.zig" },
    });
    exe.addLibraryPath("target/release");
    exe.linkSystemLibraryName("zFFI");
    exe.linkLibC();
    exe.addModule("binding", binding);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const cargo_step = b.step("cargo", "Run cargo build");
    cargo_step.dependOn(&rustlib.step);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn cargo(b: *Build, opt: Mode) *std.build.RunStep {
    const mode = switch (opt) {
        .ReleaseSafe, .ReleaseFast, .ReleaseSmall => "-r",
        else => "-v",
    };
    return b.addSystemCommand(&[_][]const u8{
        "cargo",
        "build",
        mode,
    });
}
