const std = @import("std");
const cimgui = @import("cimgui");

var b: *std.Build = undefined;

var cfg: struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.Optimize,
} = undefined;

var deps: struct {
    sokol: *std.Build.Dependency,
    cimgui: *std.Build.Dependency,
    cimgui_conf: cimgui.Config,
} = undefined;

pub fn build(b_: *std.Build) void {
    b = b_;

    cfg = .{
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    };

    deps.sokol = b.dependency("sokol", .{
        .target = cfg.target,
        .optimize = cfg.optimize,
        .with_sokol_imgui = true,
        .with_tracing = true,
    });

    deps.cimgui = b.dependency("cimgui", .{
        .target = cfg.target,
        .optimize = cfg.optimize,
    });

    deps.cimgui_conf = cimgui.getConfig(false);

    const cimgui_include = deps.cimgui.path(deps.cimgui_conf.include_dir);
    deps.sokol.artifact("sokol_clib").root_module.addIncludePath(cimgui_include);

    build_stage("01-window");
    build_stage("02-triangle");
}

fn build_stage(name: []const u8) void {
    const mod = b.createModule(.{
        .root_source_file = b.path(b.pathJoin(&[_][]const u8{ "src", name, "main.zig" })),
        .target = cfg.target,
        .optimize = cfg.optimize,
        .imports = &.{
            .{ .name = "sokol", .module = deps.sokol.module("sokol") },
            .{ .name = "cimgui", .module = deps.cimgui.module(deps.cimgui_conf.module_name) },
        },
    });

    const exe = b.addExecutable(.{
        .name = name,
        .root_module = mod,
    });
    b.installArtifact(exe);
    const run_name = std.fmt.allocPrint(b.allocator, "run-{s}", .{name}) catch unreachable;
    b.step(run_name, "run stage").dependOn(&b.addRunArtifact(exe).step);
}
