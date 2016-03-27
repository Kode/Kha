#version 100

attribute vec3 vertexPosition;
attribute vec2 texPosition;
attribute vec4 vertexColor;
uniform mat4 projectionMatrix;
varying vec2 texCoord;
varying vec4 color;

void kore() {
	gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);
	texCoord = texPosition;
	color = vertexColor;
}
