//! Zig build system framework tour.
//!
//! Covers the build graph, compilation targets, optimisation modes,
//! modules, dependencies, test steps, run steps and build options.

const std = @import("std");

/// Entry point called by `zig build`.
///
/// The build runner invokes this with a configured `*std.Build`;
/// everything declared here becomes a node in the build graph.
pub fn build(b: *std.Build) void {
    // ---- user-selectable options ----------------------------------
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSafe,
    });

    const enable_tracing = b.option(
        bool,
        "tracing",
        "Emit verbose trace logs at runtime",
    ) orelse false;

    const max_entries = b.option(u32, "max-entries", "Repository capacity") orelse 1024;

    // ---- generated build options module ---------------------------
    const options = b.addOptions();
    options.addOption(bool, "enable_tracing", enable_tracing);
    options.addOption(u32, "max_entries", max_entries); // inline comment

    // ---- the library ----------------------------------------------
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_mod.addOptions("build_options", options);

    const lib = b.addStaticLibrary(.{
        .name = "coolest",
        .root_module = lib_mod,
    });
    lib.linkLibC();
    b.installArtifact(lib);

    // ---- the executable -------------------------------------------
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("coolest", lib_mod);

    const exe = b.addExecutable(.{
        .name = "coolest",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    // ---- run step --------------------------------------------------
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    // ---- tests -----------------------------------------------------
    const lib_tests = b.addTest(.{ .root_module = lib_mod });
    const exe_tests = b.addTest(.{ .root_module = exe_mod });

    const run_lib_tests = b.addRunArtifact(lib_tests);
    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run all unit tests");
    test_step.dependOn(&run_lib_tests.step);
    test_step.dependOn(&run_exe_tests.step);

    // ---- cross-compilation matrix ----------------------------------
    const targets = [_]std.Target.Query{
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
        .{ .cpu_arch = .aarch64, .os_tag = .macos },
        .{ .cpu_arch = .wasm32, .os_tag = .wasi },
    };

    const dist_step = b.step("dist", "Cross-compile for every supported target");

    for (targets) |query| {
        const resolved = b.resolveTargetQuery(query);
        const cross_mod = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = resolved,
            .optimize = .ReleaseFast,
        });

        const cross_exe = b.addExecutable(.{ .name = "coolest", .root_module = cross_mod });

        const install = b.addInstallArtifact(cross_exe, .{
            .dest_dir = .{ .override = .{ .custom = query.zigTriple(b.allocator) catch "unknown" } },
        });
        dist_step.dependOn(&install.step);
    }
}
