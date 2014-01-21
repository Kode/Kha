package kha.graphics;

import kha.Blob;
import kha.Color;
import kha.Image;
import kha.Rectangle;

interface Graphics {
	function init(?backbufferFormat: TextureFormat, antiAliasingSamples: Int = 1): Void;
	
	function vsynced(): Bool;
	function refreshRate(): Int;
	
	function clear(?color: Color, ?depth: Float, ?stencil: Int): Void;
	
	function setCullMode(mode: CullMode): Void;
	function setDepthMode(write: Bool, mode: CompareMode): Void;
	function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void; // One, Zero deactivates blending
	function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void;
	function setScissor(rect: Rectangle): Void;
	
	function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): VertexBuffer;
	function setVertexBuffer(vertexBuffer: VertexBuffer): Void;
	
	function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): IndexBuffer;
	function setIndexBuffer(indexBuffer: IndexBuffer): Void;
	
	function createTexture(width: Int, height: Int, format: TextureFormat, usage: Usage, canRead: Bool = false, levels: Int = 1): Texture;
	function setTexture(unit: TextureUnit, texture: Image): Void;
	function setTextureParameters(texunit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void;
	function maxTextureSize(): Int;
	function supportsNonPow2Textures(): Bool;
	function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap;
	
	function createRenderTargetTexture(width: Int, height: Int, format: TextureFormat, depthStencil: Bool, antiAliasingSamples: Int = 1): Texture;
	function renderToTexture(texture: Texture): Void;
	function renderToBackbuffer(): Void;
	
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
