#version 450

uniform samplerVideo tex;
in vec2 texCoord;
in vec4 color;
out vec4 FragColor;

void main() {
	vec4 texcolor = texture(tex, texCoord) * color;
	texcolor.rgb *= color.a;
	FragColor = texcolor;
}
