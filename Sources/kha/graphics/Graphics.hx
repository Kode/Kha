package kha.graphics;

import kha.Image;

interface Graphics {
	function createVertexBuffer(vertexCount: Int): VertexBuffer;
	function createIndexBuffer(indexCount: Int): IndexBuffer;
	function createTexture(image: Image): Texture;
	function drawIndexedVertices(start: Int = 0, ?count: Int): Void;
}