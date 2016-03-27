#version 100

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 fragmentColor;

void kore() {
	gl_FragColor = fragmentColor;
}
