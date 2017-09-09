package kha.html5worker;

import haxe.ds.Vector;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;

class Graphics implements kha.graphics4.Graphics {
	public function new(renderTarget: Canvas = null) {
		
	}

	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		Worker.postMessage({ command: 'begin' });
	}

	public function beginFace(face: Int): Void {

	}

	public function beginEye(eye: Int): Void {

	}

	public function end(): Void {
		Worker.postMessage({ command: 'end' });
	}

	public function flush(): Void {

	}

	public function vsynced(): Bool {
		return true;
	}

	public function refreshRate(): Int {
		return 60;
	}

	public function clear(?color: Color, ?depth: Float, ?stencil: Int): Void {
		Worker.postMessage({ command: 'clear', color: color == null ? null : color.value, depth: depth, stencil: stencil });
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {
		
	}

	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
		return new VertexBuffer(vertexCount, structure, usage);
	}

	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		Worker.postMessage({ command: 'setVertexBuffer', id: vertexBuffer._id });
	}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
	
	}

	public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics4.IndexBuffer {
		return new IndexBuffer(indexCount, usage);
	}

	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		Worker.postMessage({ command: 'setIndexBuffer', id: indexBuffer._id });
	}

	public function setTexture(stage: kha.graphics4.TextureUnit, texture: kha.Image): Void {
	
	}
	
	public function setTextureDepth(stage: kha.graphics4.TextureUnit, texture: kha.Image): Void {
	
	}
	
	public function setTextureArray(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
	
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {
	
	}

	public function setImageTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {

	}

	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		
	}

	public function setTexture3DParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
	
	}

	public function setCubeMap(stage: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {

	}
	
	public function setCubeMapDepth(stage: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {

	}

	public function setPipeline(pipe: PipelineState): Void {
		Worker.postMessage({ command: 'setPipeline', id: pipe._id });
	}

	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {

	}

	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {

	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: FastFloat): Void {
		
	}

	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		
	}

	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		
	}

	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		
	}

	public function setFloats(location: kha.graphics4.ConstantLocation, values: Vector<FastFloat>): Void {
		
	}

	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		
	}

	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		
	}

	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		
	}

	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		
	}

	public inline function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: FastMatrix3): Void {
		
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		Worker.postMessage({ command: 'drawIndexedVertices', start: start, count: count });
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		
	}

	public function disableScissor(): Void {
		
	}

	public function renderTargetsInvertedY(): Bool {
		return true;
	}

	public function drawIndexedVerticesInstanced(instanceCount : Int, start: Int = 0, count: Int = -1) {
		
	}

	public function instancedRenderingAvailable(): Bool {
		return false;
	}
}
