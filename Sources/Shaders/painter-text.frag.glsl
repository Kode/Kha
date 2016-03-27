#version 100

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
varying vec2 texCoord;
varying vec4 fragmentColor;

void kore() {
	gl_FragColor = vec4(fragmentColor.rgb, texture2D(tex, texCoord).r * fragmentColor.a);
}
