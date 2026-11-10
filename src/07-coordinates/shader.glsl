@header const za = @import("zalgebra")
@ctype mat4 za.Mat4

@vs vs

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

layout(binding = 0) uniform vs_params {
    mat4 model;
    mat4 view;
    mat4 projection;
};

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    TexCoord = aTexCoord;
}
@end

@fs fs
layout(binding=0) uniform texture2D tex0;
layout(binding=1) uniform texture2D tex1;
layout(binding=0) uniform sampler smp;

out vec4 FragColor;

in vec2 TexCoord;

// uniform sampler2D ourTexture;

void main() {
    FragColor = mix(
        texture(sampler2D(tex0, smp), TexCoord),
        texture(sampler2D(tex1, smp), TexCoord * vec2(-1.0, 1.0)),
        0.2
    );
}
@end

@program shader vs fs
