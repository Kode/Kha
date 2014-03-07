/*
uniform mat4 projection;
uniform mat4 view;
uniform mat4 world;
uniform mat4 worldRotation;
uniform mat4 lightworld;
uniform mat4 lightview;
uniform mat4 lightprojection;

attribute vec4 vPos;
attribute vec4 vCol;
attribute vec2 vTex;
attribute vec4 vNormal;
attribute vec3 vTangent;

varying vec4 oCol;
varying vec2 oTex;
varying vec4 worldPosition;
varying vec3 normal;
varying vec4 positionFromLight;
varying vec3 tangent;
varying vec4 clipPosition;
*/
void kore() {
	gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
	/*
	oCol = vCol;
	vec4 position = vPos;
	worldPosition = world * position;
	normal = normalize((worldRotation * vNormal).xyz);
	tangent = normalize((worldRotation * vTangent).xyz);
	gl_position = projection * view * world * vPos;
	clipPosition = oPos;
	oTex = vTex;
	positionFromLight = lightprojection * lightview * lighworld * vPos;
	*/
}
