#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 texPosition;
layout(location = 2) in vec4 vertexColor;
layout(location = 0) out vec2 texCoord;
layout(location = 1) out vec4 color;

layout(std140, binding = 0) uniform _k_global_uniform_buffer_type {
	mat4 projectionMatrix;
} _k_global_uniform_buffer;

void kore() {
	vec4 temp = _k_global_uniform_buffer.projectionMatrix * vec4(vertexPosition, 1.0);
	temp.z = 0.5;
	gl_Position = temp;
	texCoord = texPosition;
	color = vertexColor;
}
