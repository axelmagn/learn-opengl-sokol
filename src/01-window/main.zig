const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const sg = sokol.gfx;
const sglue = sokol.glue;
const simgui = sokol.imgui;
const slog = sokol.log;

var state = struct {}{};

export fn init() void {
    // init gfx
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

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
}

export fn cleanup() void {}

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
