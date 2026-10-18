@vs vs

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 ourColor;
out vec2 TexCoord;

void main() {
    gl_Position = vec4(aPos, 1.0);
    ourColor = aColor;
    TexCoord = aTexCoord;
}
@end

@fs fs
layout(binding=0) uniform texture2D tex0;
layout(binding=1) uniform texture2D tex1;
layout(binding=0) uniform sampler smp;

out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

// uniform sampler2D ourTexture;

void main() {
    // frag_color = texture(sampler2D(tex, smp), fs_uv);
    FragColor = mix(
        texture(sampler2D(tex0, smp), TexCoord),
        // texture(sampler2D(tex1, smp), TexCoord),
        texture(sampler2D(tex1, smp), TexCoord * vec2(-1.0, 1.0)),
        0.2
    );
    // FragColor = texture(sampler2D(tex0 ,smp), TexCoord) * vec4(ourColor, 1.0);
    // FragColor = texture(ourTexture, TexCoord);
}
@end

@program shader vs fs
