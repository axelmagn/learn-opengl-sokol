@vs vs
in vec3 position;

void main() {
    gl_Position = vec4(position, 1.0);
}
@end

@fs fs
out vec4 frag_color;

void main() {
    frag_color = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
@end

@program triangle vs fs
