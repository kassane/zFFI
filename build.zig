const std = @import("std");
const Build = std.Build;
const Mode = std.builtin.OptimizeMode;

pub fn build(b: *Build) void {
    var target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // for Windows overwritten default abi (mingw to msvc)
    if (target.isWindows()) {
        target.abi = .msvc; // default to rust
    }

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
    if (optimize == .Debug)
        exe.addLibraryPath(.{ .path = "target/debug" })
    else
        exe.addLibraryPath(.{ .path = "target/release" });
    exe.linkSystemLibrary("zFFI");
    if (target.isWindows()) {
        exe.linkSystemLibrary("ws2_32");
        exe.linkSystemLibrary("bcrypt");
        exe.linkSystemLibrary("advapi32");
        exe.linkSystemLibrary("userenv");
    }
    if (target.getAbi() == .msvc)
        exe.linkLibC()
    else
        exe.linkLibCpp();
    exe.addModule("binding", binding);
    exe.step.dependOn(&rustlib.step);
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

fn cargo(b: *Build, opt: Mode) *std.build.Step.Run {
    const mode = switch (opt) {
        .ReleaseSafe, .ReleaseFast, .ReleaseSmall => "-r",
        else => "-q",
    };
    return b.addSystemCommand(&[_][]const u8{
        "cargo",
        "build",
        mode,
    });
}
