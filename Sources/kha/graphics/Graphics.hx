package kha.graphics;

import kha.Image;

interface Graphics {
	function createVertexBuffer(vertexCount: Int, stride: Int): VertexBuffer;
	function setVertexBuffer(vertexBuffer: VertexBuffer): Void;
	function createIndexBuffer(indexCount: Int): IndexBuffer;
	function createTexture(image: Image): Texture;
	function drawIndexedVertices(start: Int = 0, ?count: Int): Void;
	function drawArrays(start: Int = 0, ?count: Int): Void;
	function createVertexShader(source: String): VertexShader;
	function createFragmentShader(source: String): FragmentShader;
	function setVertexShader(shader: VertexShader): Void;
	function setFragmentShader(shader: FragmentShader): Void;
	function linkShaders(): Void;
}