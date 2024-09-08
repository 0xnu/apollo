const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zigimg_dep = b.dependency("zigimg", .{
        .target = target,
        .optimize = optimize,
    });

    // Apollo Library
    const apollo_lib = b.addStaticLibrary(.{
        .name = "apollo",
        .root_source_file = b.path("src/apollo.zig"),
        .target = target,
        .optimize = optimize,
    });
    apollo_lib.root_module.addImport("zigimg", zigimg_dep.module("zigimg"));
    b.installArtifact(apollo_lib);

    // Apollo Module
    const apollo_module = b.addModule("apollo", .{
        .root_source_file = b.path("src/apollo.zig"),
        .imports = &.{
            .{ .name = "zigimg", .module = zigimg_dep.module("zigimg") },
        },
    });

    // Executable Example
    const exe = b.addExecutable(.{
        .name = "apollo-example",
        .root_source_file = b.path("examples/example.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zigimg", zigimg_dep.module("zigimg"));
    exe.root_module.addImport("apollo", apollo_module);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Execute the example application");
    run_step.dependOn(&run_cmd.step);

    // Test
    const lib_tests = b.addTest(.{
        .root_source_file = b.path("src/apollo.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_tests.root_module.addImport("zigimg", zigimg_dep.module("zigimg"));

    const run_lib_tests = b.addRunArtifact(lib_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_tests.step);
}
