#version 450

in vec3 vertexPosition;
in vec2 vertexUV;
in vec4 vertexColor;
in float vertexTexIndex;
uniform mat4 projectionMatrix;
out float texIndex;
out vec2 texCoord;
out vec4 color;

void main() {
	gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);
	texCoord = vertexUV;
	color = vertexColor;
	texIndex = vertexTexIndex;
}
