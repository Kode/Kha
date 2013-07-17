#version 100

#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D tex;
varying vec2 texCoord;
varying vec4 fragmentColor;

void kmain() {
	gl_FragColor = vec4(fragmentColor.rgb, texture2D(tex, texCoord).r);
}
