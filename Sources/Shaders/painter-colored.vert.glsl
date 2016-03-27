#version 100

attribute vec3 vertexPosition;
attribute vec4 vertexColor;
uniform mat4 projectionMatrix;
varying vec4 fragmentColor;

void kore() {
	gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);
	fragmentColor = vertexColor;
}
