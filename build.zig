const std = @import("std");
const Build = std.Build;
const Mode = std.builtin.OptimizeMode;

pub fn build(b: *Build) !void {
    // for Windows overwritten default abi (mingw to msvc)
    const target = b.standardTargetOptions(.{ .default_target = if (@import("builtin").os.tag == .windows)
        try std.Target.Query.parse(.{ .arch_os_abi = "native-windows-msvc" })
    else
        .{} });
    const optimize = b.standardOptimizeOption(.{});

    // Make binding Module
    const binding = b.addModule("binding", .{
        .root_source_file = .{ .path = "generated/binding.zig" },
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
    if (exe.rootModuleTarget().os.tag == .windows) {
        exe.linkSystemLibrary("ws2_32");
        exe.linkSystemLibrary("bcrypt");
        exe.linkSystemLibrary("advapi32");
        exe.linkSystemLibrary("userenv");
    }
    if (exe.rootModuleTarget().abi == .msvc)
        exe.linkLibC()
    else
        exe.linkLibCpp();
    exe.root_module.addImport("binding", binding);
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

fn cargo(b: *Build, opt: Mode) *Build.Step.Run {
    const mode: []const u8 = switch (opt) {
        .ReleaseSafe, .ReleaseFast, .ReleaseSmall => "-r",
        else => "",
    };
    var args = b.addSystemCommand(&[_][]const u8{
        "cargo",
        "build",
        "-q",
    });
    if (!std.mem.eql(u8, mode, ""))
        args.addArg(mode);
    return args;
}
