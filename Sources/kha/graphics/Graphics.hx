package kha.graphics;

import kha.Image;

interface Graphics {
	function createVertexBuffer(vertexCount: Int, structure: VertexStructure): VertexBuffer;
	function setVertexBuffer(vertexBuffer: VertexBuffer): Void;
	
	function createIndexBuffer(indexCount: Int): IndexBuffer;
	function setIndexBuffer(indexBuffer: IndexBuffer): Void;
	
	function createTexture(image: Image): Texture;
	function setTextureWrap(stage: Int, u: TextureWrap, v: TextureWrap): Void;
	
	function createVertexShader(source: String): VertexShader;
	function createFragmentShader(source: String): FragmentShader;
	function createProgram(): Program;
	function setProgram(program: Program): Void;
	//function setVertexShader(shader: VertexShader): Void;
	//function setFragmentShader(shader: FragmentShader): Void;
	//function linkShaders(): Void;
	
	function drawIndexedVertices(start: Int = 0, ?count: Int): Void;
}
