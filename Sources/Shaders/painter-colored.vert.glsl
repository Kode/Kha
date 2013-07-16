#version 100

attribute vec3 vertexPosition;
uniform mat4 projectionMatrix;

void kmain() {
	gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);
}
