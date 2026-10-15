const std = @import("std");
const cimgui = @import("cimgui");
const sokol = @import("sokol");

var b: *std.Build = undefined;

var cfg: struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.Optimize,
} = undefined;

var deps: struct {
    sokol: *std.Build.Dependency,
    cimgui: *std.Build.Dependency,
    cimgui_conf: cimgui.Config,
    shdc: *std.Build.Dependency,
} = undefined;

pub fn build(b_: *std.Build) !void {
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

    deps.shdc = deps.sokol.builder.dependency("shdc", .{});

    const cimgui_include = deps.cimgui.path(deps.cimgui_conf.include_dir);
    deps.sokol.artifact("sokol_clib").root_module.addIncludePath(cimgui_include);

    try build_stage("01-window", &.{});
    try build_stage("02-triangle", &.{"triangle"});
    try build_stage("03-quad", &.{"quad"});
}

fn build_stage(
    name: []const u8,
    shader_names: []const []const u8,
) !void {
    const mod = b.createModule(.{
        .root_source_file = b.path(b.pathJoin(&.{ "src", name, "main.zig" })),
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

    for (shader_names) |shader_name| {
        const shader_in = b.pathJoin(&.{ "src", name, b.fmt("{s}.glsl", .{shader_name}) });
        const shader_out = b.pathJoin(&.{ "src", name, b.fmt("{s}.zig", .{shader_name}) });
        const shdc_step = try sokol.shdc.createSourceFile(b, .{
            .shdc_dep = deps.shdc,
            .input = shader_in,
            .output = shader_out,
            .slang = .{
                .glsl430 = true,
                .glsl310es = true,
                .metal_macos = true,
                .hlsl5 = true,
                .wgsl = true,
                .spirv_vk = true,
            },
            .reflection = true,
        });
        exe.step.dependOn(shdc_step);
    }

    b.installArtifact(exe);
    const run_name = std.fmt.allocPrint(b.allocator, "run-{s}", .{name}) catch unreachable;
    b.step(run_name, "run stage").dependOn(&b.addRunArtifact(exe).step);
}
