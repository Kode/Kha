#version 450

uniform sampler2D tex0;
uniform sampler2D tex1;
uniform sampler2D tex2;
uniform sampler2D tex3;
uniform sampler2D tex4;
uniform sampler2D tex5;
uniform sampler2D tex6;
uniform sampler2D tex7;
in float texIndex;
in vec2 texCoord;
in vec4 color;
out vec4 FragColor;

void main() {
	vec4 texcolor;
	if (texIndex < 0.5) {
		texcolor = texture(tex0, texCoord) * color;
	} else if (texIndex < 1.5) {
		texcolor = texture(tex1, texCoord) * color;
	} else if (texIndex < 2.5) {
		texcolor = texture(tex2, texCoord) * color;
	} else if (texIndex < 3.5) {
		texcolor = texture(tex3, texCoord) * color;
	} else if (texIndex < 4.5) {
		texcolor = texture(tex4, texCoord) * color;
	} else if (texIndex < 5.5) {
		texcolor = texture(tex5, texCoord) * color;
	} else if (texIndex < 6.5) {
		texcolor = texture(tex6, texCoord) * color;
	} else {
		texcolor = texture(tex7, texCoord) * color;
	}
	texcolor.rgb *= color.a;
	FragColor = texcolor;
}
