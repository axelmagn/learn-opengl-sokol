@vs vs
in vec3 position;
in vec2 uv;

out vec2 fs_uv;

void main() {
    gl_Position = vec4(position, 1.0);
    fs_uv = uv;
}
@end

@fs fs
layout(binding=0) uniform texture2D tex;
layout(binding=0) uniform sampler smp;

in vec2 fs_uv;
out vec4 frag_color;

void main() {
    frag_color = texture(sampler2D(tex, smp), fs_uv);
}
@end

@program shader vs fs
