#version 400
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(binding = 2) uniform sampler2D tex;
layout(location = 0) in vec2 texCoord;
layout(location = 1) in vec4 color;

void kore() {
	vec4 texcolor = texture2D(tex, texCoord) * color;
	texcolor.rgb *= color.a;
	gl_FragColor = texcolor;
}
