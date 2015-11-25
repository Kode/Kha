package kha.graphics4;



import kha.Blob;
import kha.Color;
import kha.Image;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Video;

interface Graphics {
	function begin(): Void;
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
	//function renderToTexture(texture: Texture): Void;
	//function renderToBackbuffer(): Void;
	
	function setPipeline(pipeline: PipelineState): Void;
	
	function setBool(location: ConstantLocation, value: Bool): Void;
	function setInt(location: ConstantLocation, value: Int): Void;
	function setFloat(location: ConstantLocation, value: Float): Void;
	function setFloat2(location: ConstantLocation, value1: Float, value2: Float): Void;
	function setFloat3(location: ConstantLocation, value1: Float, value2: Float, value3: Float): Void;
	function setFloat4(location: ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void;
	function setFloats(location: ConstantLocation, floats: Array<Float>): Void;
	function setVector2(location: ConstantLocation, value: Vector2): Void;
	function setVector3(location: ConstantLocation, value: Vector3): Void;
	function setVector4(location: ConstantLocation, value: Vector4): Void;
	function setMatrix(location: ConstantLocation, value: Matrix4): Void;
	
	function drawIndexedVertices(start: Int = 0, count: Int = -1): Void;
	function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void;
	
	function flush(): Void;
}
