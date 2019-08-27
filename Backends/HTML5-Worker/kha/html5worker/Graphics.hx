package kha.html5worker;

import kha.arrays.Float32Array;
import kha.Canvas;
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
	var renderTarget: Image;

	public function new(renderTarget: Canvas = null) {
		if (Std.is(renderTarget, Image)) {
			this.renderTarget = cast renderTarget;
		}
	}

	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		Worker.postMessage({ command: 'begin', renderTarget: renderTarget == null ? -1 : renderTarget._rtid });
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
		Worker.postMessage({ command: 'clear', color: color == null ? null : color.value, hasDepth: depth != null, depth: depth, hasStencil: stencil != null, stencil: stencil });
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {
		Worker.postMessage({ command: 'viewport', x: x, y: y, width: width, height: height });
	}

	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
		return new VertexBuffer(vertexCount, structure, usage);
	}

	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		Worker.postMessage({ command: 'setVertexBuffer', id: vertexBuffer._id });
	}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
		var ids = new Array<Int>();
		for (buffer in vertexBuffers) {
			ids.push(buffer._id);
		}
		Worker.postMessage({ command: 'setVertexBuffers', ids: ids });
	}

	public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics4.IndexBuffer {
		return new IndexBuffer(indexCount, usage);
	}

	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		Worker.postMessage({ command: 'setIndexBuffer', id: indexBuffer._id });
	}

	public function setTexture(stage: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		Worker.postMessage({ command: 'setTexture', stage: cast(stage, kha.html5worker.TextureUnit)._id,
			texture: texture == null ? -1 : texture.id, renderTarget: texture == null ? -1 : texture._rtid });
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
		Worker.postMessage({ command: 'setTextureParameters', id: cast(texunit, kha.html5worker.TextureUnit)._id,
			uAddressing: uAddressing, vAddressing: vAddressing,
			minificationFilter: minificationFilter, magnificationFilter: magnificationFilter, mipmapFilter: mipmapFilter
		});
	}

	public function setTexture3DParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {

	}

	public function setTextureCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool): Void {

	}

	public function setCubeMapCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool): Void {

	}

	public function setCubeMap(stage: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {

	}

	public function setCubeMapDepth(stage: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {

	}

	public function setPipeline(pipe: PipelineState): Void {
		Worker.postMessage({ command: 'setPipeline', id: pipe._id });
	}

	public function setStencilReferenceValue(value: Int): Void {

	}

	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		Worker.postMessage({ command: 'setBool', location: cast(location, kha.html5worker.ConstantLocation)._id,
			value: value});
	}

	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		Worker.postMessage({ command: 'setInt', location: cast(location, kha.html5worker.ConstantLocation)._id,
			value: value});
	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: FastFloat): Void {
		Worker.postMessage({ command: 'setFloat', location: cast(location, kha.html5worker.ConstantLocation)._id,
			value: value});
	}

	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		Worker.postMessage({ command: 'setFloat2', location: cast(location, kha.html5worker.ConstantLocation)._id,
			_0: value1, _1: value2});
	}

	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		Worker.postMessage({ command: 'setFloat3', location: cast(location, kha.html5worker.ConstantLocation)._id,
			_0: value1, _1: value2, _2: value3});
	}

	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		Worker.postMessage({ command: 'setFloat4', location: cast(location, kha.html5worker.ConstantLocation)._id,
			_0: value1, _1: value2, _2: value3, _3: value4});
	}

	public function setFloats(location: kha.graphics4.ConstantLocation, values: Float32Array): Void {
		Worker.postMessage({ command: 'setFloats', location: cast(location, kha.html5worker.ConstantLocation)._id,
			values: values});
	}

	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		Worker.postMessage({ command: 'setVector2', location: cast(location, kha.html5worker.ConstantLocation)._id,
			x: value.x, y: value.y});
	}

	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		Worker.postMessage({ command: 'setVector3', location: cast(location, kha.html5worker.ConstantLocation)._id,
			x: value.x, y: value.y, z: value.z});
	}

	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		Worker.postMessage({ command: 'setVector4', location: cast(location, kha.html5worker.ConstantLocation)._id,
			x: value.x, y: value.y, z: value.z, w: value.w});
	}

	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		Worker.postMessage({ command: 'setMatrix4', location: cast(location, kha.html5worker.ConstantLocation)._id,
			_00: matrix._00, _01: matrix._01, _02: matrix._02, _03: matrix._03,
			_10: matrix._10, _11: matrix._11, _12: matrix._12, _13: matrix._13,
			_20: matrix._20, _21: matrix._21, _22: matrix._22, _23: matrix._23,
			_30: matrix._30, _31: matrix._31, _32: matrix._32, _33: matrix._33
		});
	}

	public inline function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: FastMatrix3): Void {
		Worker.postMessage({ command: 'setMatrix3', location: cast(location, kha.html5worker.ConstantLocation)._id,
			_00: matrix._00, _01: matrix._01, _02: matrix._02,
			_10: matrix._10, _11: matrix._11, _12: matrix._12,
			_20: matrix._20, _21: matrix._21, _22: matrix._22
		});
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		Worker.postMessage({ command: 'drawIndexedVertices', start: start, count: count });
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		Worker.postMessage({ command: 'scissor', x: x, y: y, width: width, height: height });
	}

	public function disableScissor(): Void {
		Worker.postMessage({ command: 'disableScissor' });
	}

	public function drawIndexedVerticesInstanced(instanceCount : Int, start: Int = 0, count: Int = -1) {
		Worker.postMessage({ command: 'drawIndexedVerticesInstanced', instanceCount: instanceCount, start: start, count: count });
	}

	public function instancedRenderingAvailable(): Bool {
		return true;
	}
}
