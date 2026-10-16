const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const sg = sokol.gfx;
const sglue = sokol.glue;
const simgui = sokol.imgui;
const slog = sokol.log;

const shd = @import("quad.glsl.zig");

var state = struct {
    bind: sg.Bindings = .{},
    pipe: sg.Pipeline = .{},
}{};

export fn init() void {
    // init gfx
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    // create vertex buffer with quad verts
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            // positions
            0.5, 0.5, 0.0, // top right
            0.5, -0.5, 0.0, // bottom right
            -0.5, -0.5, 0.0, // bottom left
            -0.5, 0.5, 0.0, // top left
        }),
    });

    state.bind.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },
        .data = sg.asRange(&[_]u16{ 0, 1, 2, 0, 2, 3 }),
    });

    // create shader
    const backend = sg.queryBackend();
    const shader_desc = shd.triangleShaderDesc(backend);
    const shader = sg.makeShader(shader_desc);

    // create pipeline
    var pipe_desc = sg.PipelineDesc{ .shader = shader, .index_type = .UINT16 };
    pipe_desc.layout.attrs[shd.ATTR_triangle_position].format = .FLOAT3;
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
    sg.draw(0, 6, 1);
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
