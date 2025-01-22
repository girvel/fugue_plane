extern mat4 projection;
extern mat4 view;

vec4 position(mat4 transform_projection, vec4 vertex_position) {
    return projection * view * vertex_position;
}
