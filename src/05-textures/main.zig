const std = @import("std");
const log = std.log.scoped(.app);
const sokol = @import("sokol");
const ig = @import("cimgui");
const sapp = sokol.app;
const sg = sokol.gfx;
const sglue = sokol.glue;
const simgui = sokol.imgui;
const slog = sokol.log;
const clib = @import("clib");
const shd = @import("shader.glsl.zig");

var state = struct {
    proc: std.process.Init = undefined,
    bind: sg.Bindings = .{},
    pipe: sg.Pipeline = .{},
    textures: struct {
        wall: [*c]u8 = undefined,
    } = .{},
}{};

const wall_bytes = @embedFile("wall.jpg");

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

    // load wall texture
    var wall_width: c_int = undefined;
    var wall_height: c_int = undefined;
    var wall_channels: c_int = undefined;
    const wall_ctex = clib.stbi_load_from_memory(
        wall_bytes.ptr,
        @intCast(wall_bytes.len),
        &wall_width,
        &wall_height,
        &wall_channels,
        4,
    );
    defer clib.stbi_image_free(wall_ctex);

    // bind wall texture
    const wall_tex_len: usize = @intCast(wall_width * wall_height * 4);
    const wall_tex: []u8 = wall_ctex[0..wall_tex_len];
    var wall_img_data = sg.ImageData{};
    wall_img_data.mip_levels[0] = sg.asRange(wall_tex);
    const wall_img = sg.makeImage(.{
        .width = wall_width,
        .height = wall_height,
        .data = wall_img_data,
    });
    state.bind.views[shd.VIEW_tex] = sg.makeView(.{ .texture = .{ .image = wall_img } });
    state.bind.samplers[shd.SMP_smp] = sg.makeSampler(.{});

    // create shader
    const backend = sg.queryBackend();
    const shader_desc = shd.shaderShaderDesc(backend);
    const shader = sg.makeShader(shader_desc);

    // create pipeline
    var pipe_desc = sg.PipelineDesc{ .shader = shader };
    pipe_desc.layout.attrs[shd.ATTR_shader_position].format = .FLOAT3;
    pipe_desc.layout.attrs[shd.ATTR_shader_uv].format = .FLOAT2;
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

pub fn main(proc: std.process.Init) void {
    state.proc = proc;
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
