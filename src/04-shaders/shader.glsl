@vs vs
in vec3 position;
in vec3 color;

out vec3 vert_color;

void main() {
    gl_Position = vec4(position, 1.0);
    vert_color = color;
}
@end

@fs fs
in vec3 vert_color;
out vec4 frag_color;

void main() {
    frag_color = vec4(vert_color, 1.0);
}
@end

@program shader vs fs
