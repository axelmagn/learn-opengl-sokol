const std = @import("std");
const sokol = @import("sokol");
const ig = @import("cimgui");
const sapp = sokol.app;
const sg = sokol.gfx;
const sglue = sokol.glue;
const simgui = sokol.imgui;
const slog = sokol.log;
const cstbi = @import("cstbi");
const shd = @import("shader.glsl.zig");

var state = struct {
    bind: sg.Bindings = .{},
    pipe: sg.Pipeline = .{},
}{};

const image_bytes = @embedFile("wall.jpg");

export fn init() void {
    // init gfx
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    // create vertex buffer with triangle verts
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            // positions   // uv
            0.0, 0.5, 0.0, 0.5, 1.0, // top
            0.5, -0.5, 0.0, 1.0, 0.0, // right
            -0.5, -0.5, 0.0, 0.0, 0.0, // left
        }),
    });

    // create shader
    const backend = sg.queryBackend();
    const shader_desc = shd.shaderShaderDesc(backend);
    const shader = sg.makeShader(shader_desc);

    // create pipeline
    var pipe_desc = sg.PipelineDesc{ .shader = shader };
    pipe_desc.layout.attrs[shd.ATTR_shader_position].format = .FLOAT3;
    pipe_desc.layout.attrs[shd.ATTR_shader_color].format = .FLOAT3;
    state.pipe = sg.makePipeline(pipe_desc);

    // init imgui
    simgui.setup(.{ .logger = .{ .func = slog.func } });
}

export fn frame() void {
    draw_ui();
    draw();
}

fn draw_ui() void {
    simgui.newFrame(.{
        .width = sapp.width(),
        .height = sapp.height(),
        .delta_time = sapp.frameDuration(),
        .dpi_scale = sapp.dpiScale(),
    });
    defer simgui.flush();

    // UI CODE HERE
}

fn draw() void {
    var pass_action: sg.PassAction = .{};
    pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.2, .g = 0.3, .b = 0.3, .a = 1.0 },
    };
    sg.beginPass(.{ .action = pass_action, .swapchain = sglue.swapchain() });
    defer sg.commit();
    defer sg.endPass();

    // DRAW CODE HERE
    sg.applyPipeline(state.pipe);
    sg.applyBindings(state.bind);

    sg.draw(0, 3, 1);
}

export fn cleanup() void {
    sg.shutdown();
}

export fn event(ev: [*c]const sapp.Event) void {
    _ = ev;
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .window_title = "learn opengl",
        .width = 800,
        .height = 600,
        .logger = .{ .func = slog.func },
    });
}
