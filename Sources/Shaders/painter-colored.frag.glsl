#version 100

#ifdef GL_ES
precision highp float;
#endif

varying vec4 fragmentColor;

void kmain() {
	gl_FragColor = fragmentColor;
}
