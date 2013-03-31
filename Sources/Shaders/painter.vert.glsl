#version 100

attribute vec3 vertexPosition;
attribute vec2 texPosition;
uniform mat4 projectionMatrix;
varying vec2 texCoord;

void main() {
	gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);
	texCoord = texPosition;
}
