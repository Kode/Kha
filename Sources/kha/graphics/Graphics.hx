package kha.graphics;

import kha.Blob;
import kha.Color;
import kha.Image;

interface Graphics {
	function vsynced(): Bool;
	function refreshRate(): Int;
	
	function clear(?color: Color, ?depth: Float, ?stencil: Int): Void;
	
	function setRenderStateBool(state: RenderState, on: Bool): Void;
	function setRenderStateInt(state: RenderState, v: Int): Void;
	function setRenderStateFloat(state: RenderState, value: Float): Void;
	function setDepthMode(write: Bool, mode: DepthCompareMode): Void;
	function setTextureAddressing(unit: TextureUnit, dir: TexDir, addressing: TextureAddressing): Void;
	function setTextureMagnificationFilter(texunit: Int, filter: TextureFilter): Void;
	function setTextureMinificationFilter(texunit: Int, filter: TextureFilter): Void;
	function setTextureMipmapFilter(texunit: Int, filter: MipMapFilter): Void;
	function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void;
	function setTextureOperation(operation: TextureOperation, arg1: TextureArgument, arg2: TextureArgument): Void;

	function createVertexBuffer(vertexCount: Int, structure: VertexStructure): VertexBuffer;
	function setVertexBuffer(vertexBuffer: VertexBuffer): Void;
	
	function createIndexBuffer(indexCount: Int): IndexBuffer;
	function setIndexBuffer(indexBuffer: IndexBuffer): Void;
	
	function createTexture(width: Int, height: Int, format: TextureFormat): Texture;
	function setTexture(unit: TextureUnit, texture: Image): Void;
	function setTextureWrap(unit: TextureUnit, u: TextureWrap, v: TextureWrap): Void;
	
	function createVertexShader(source: Blob): VertexShader;
	function createFragmentShader(source: Blob): FragmentShader;
	function createProgram(): Program;
	function setProgram(program: Program): Void;
	
	function setInt(location: ConstantLocation, value: Int): Void;
	function setFloat(location: ConstantLocation, value: Float): Void;
	function setFloat2(location: ConstantLocation, value1: Float, value2: Float): Void;
	function setFloat3(location: ConstantLocation, value1: Float, value2: Float, value3: Float): Void;
	function setMatrix(location: ConstantLocation, matrix: Array<Float>): Void;
	
	function drawIndexedVertices(start: Int = 0, count: Int = -1): Void;
}
