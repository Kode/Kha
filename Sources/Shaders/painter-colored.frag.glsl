#version 100

#ifdef GL_ES
precision highp float;
#endif

uniform vec4 color;

void kmain() {
	gl_FragColor = color;
}
