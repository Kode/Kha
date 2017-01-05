#version 450

uniform sampler2D tex;
in vec2 texCoord;
in vec4 fragmentColor;

void main() {
	gl_FragColor = vec4(fragmentColor.rgb, texture(tex, texCoord).r * fragmentColor.a);
}
