#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(binding = 2) uniform sampler2D tex;
layout(location = 0) in vec2 texCoord;
layout(location = 1) in vec4 fragmentColor;
layout(location = 0) out vec4 outColor;

void kore() {
	outColor = vec4(fragmentColor.rgb, texture2D(tex, texCoord).r * fragmentColor.a);
}
