package kha.graphics4;

import haxe.ds.Vector;
import kha.Blob;
import kha.Color;
import kha.FastFloat;
import kha.Image;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.Video;

interface Graphics {
	function begin(additionalRenderTargets: Array<Canvas> = null): Void;
	function end(): Void;
	
	function vsynced(): Bool;
	function refreshRate(): Int;
	
	function clear(?color: Color, ?depth: Float, ?stencil: Int): Void;

	function viewport(x: Int, y: Int, width: Int, height: Int): Void;
	function scissor(x: Int, y: Int, width: Int, height: Int): Void;
	
	function disableScissor(): Void;
	function setVertexBuffer(vertexBuffer: VertexBuffer): Void;
	function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void;
	function setIndexBuffer(indexBuffer: IndexBuffer): Void;
	
	function setTexture(unit: TextureUnit, texture: Image): Void;
	function setVideoTexture(unit: TextureUnit, texture: Video): Void;
	function setTextureParameters(texunit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void;
	//function maxTextureSize(): Int;
	//function supportsNonPow2Textures(): Bool;
	function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap;
	
	function renderTargetsInvertedY(): Bool;
	function instancedRenderingAvailable(): Bool;
	
	function setPipeline(pipeline: PipelineState): Void;
	
	function setBool(location: ConstantLocation, value: Bool): Void;
	function setInt(location: ConstantLocation, value: Int): Void;
	function setFloat(location: ConstantLocation, value: FastFloat): Void;
	function setFloat2(location: ConstantLocation, value1: FastFloat, value2: FastFloat): Void;
	function setFloat3(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void;
	function setFloat4(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void;
	function setFloats(location: ConstantLocation, floats: Vector<FastFloat>): Void;
	function setVector2(location: ConstantLocation, value: FastVector2): Void;
	function setVector3(location: ConstantLocation, value: FastVector3): Void;
	function setVector4(location: ConstantLocation, value: FastVector4): Void;
	function setMatrix(location: ConstantLocation, value: FastMatrix4): Void;
	
	function drawIndexedVertices(start: Int = 0, count: Int = -1): Void;
	function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void;
	
	function flush(): Void;
}
