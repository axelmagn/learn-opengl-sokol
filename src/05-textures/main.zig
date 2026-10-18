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
        tex0: [*c]u8 = undefined,
    } = .{},
}{};

const tex0_bytes = @embedFile("container.jpg");
const tex1_bytes = @embedFile("awesomeface.png");

export fn init() void {
    // init gfx
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    // create vertex buffer with triangle verts
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            // positions   // colors      // texture coords
            0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, // top right
            0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, // bottom right
            -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, // bottom left
            -0.5, 0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, // top left
        }),
    });
    state.bind.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },
        .data = sg.asRange(&[_]u16{ 0, 1, 2, 0, 2, 3 }),
    });

    clib.stbi_set_flip_vertically_on_load(1);

    // load tex0 texture
    var tex0_width: c_int = undefined;
    var tex0_height: c_int = undefined;
    var tex0_channels: c_int = undefined;
    const tex0_ctex = clib.stbi_load_from_memory(
        tex0_bytes.ptr,
        @intCast(tex0_bytes.len),
        &tex0_width,
        &tex0_height,
        &tex0_channels,
        4,
    );
    defer clib.stbi_image_free(tex0_ctex);

    // bind tex0 texture
    const tex0_tex_len: usize = @intCast(tex0_width * tex0_height * 4);
    const tex0_tex: []u8 = tex0_ctex[0..tex0_tex_len];
    var tex0_img_data = sg.ImageData{};
    tex0_img_data.mip_levels[0] = sg.asRange(tex0_tex);
    const tex0_img = sg.makeImage(.{
        .width = tex0_width,
        .height = tex0_height,
        .data = tex0_img_data,
    });
    state.bind.views[shd.VIEW_tex0] = sg.makeView(.{ .texture = .{ .image = tex0_img } });

    // load tex1 texture
    var tex1_width: c_int = undefined;
    var tex1_height: c_int = undefined;
    var tex1_channels: c_int = undefined;
    const tex1_ctex = clib.stbi_load_from_memory(
        tex1_bytes.ptr,
        @intCast(tex1_bytes.len),
        &tex1_width,
        &tex1_height,
        &tex1_channels,
        4,
    );
    defer clib.stbi_image_free(tex1_ctex);

    // bind tex1 texture
    const tex1_tex_len: usize = @intCast(tex1_width * tex1_height * 4);
    const tex1_tex: []u8 = tex1_ctex[0..tex1_tex_len];
    var tex1_img_data = sg.ImageData{};
    tex1_img_data.mip_levels[0] = sg.asRange(tex1_tex);
    const tex1_img = sg.makeImage(.{
        .width = tex1_width,
        .height = tex1_height,
        .data = tex1_img_data,
    });
    state.bind.views[shd.VIEW_tex1] = sg.makeView(.{ .texture = .{ .image = tex1_img } });

    // bind sampler
    state.bind.samplers[shd.SMP_smp] = sg.makeSampler(.{});

    // create shader
    const backend = sg.queryBackend();
    const shader_desc = shd.shaderShaderDesc(backend);
    const shader = sg.makeShader(shader_desc);

    // create pipeline
    var pipe_desc = sg.PipelineDesc{ .shader = shader, .index_type = .UINT16 };
    pipe_desc.layout.attrs[shd.ATTR_shader_aPos].format = .FLOAT3;
    pipe_desc.layout.attrs[shd.ATTR_shader_aColor].format = .FLOAT3;
    pipe_desc.layout.attrs[shd.ATTR_shader_aTexCoord].format = .FLOAT2;
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
