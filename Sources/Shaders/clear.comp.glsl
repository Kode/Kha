#version 450

uniform vec4 color;
uniform writeonly image2D dest;

layout (local_size_x = 16, local_size_y = 16) in;

void main() {
	ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
	imageStore(dest, pos, color);
}
