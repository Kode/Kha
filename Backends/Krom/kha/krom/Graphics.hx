package kha.krom;

import haxe.ds.Vector;
import kha.Blob;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.CubeMap;
import kha.graphics4.CullMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.StencilAction;
import kha.graphics4.TexDir;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexShader;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;

class Graphics implements kha.graphics4.Graphics {
	private var renderTarget: kha.Canvas;
	
	public function new(renderTarget: kha.Canvas = null) {
		this.renderTarget = renderTarget;
	}

	public function begin(additionalRenderTargets: Array<kha.Canvas> = null): Void {
		Krom.begin(renderTarget, additionalRenderTargets);
	}

	public function beginFace(face: Int): Void {
		Krom.beginFace(renderTarget, face);
	}

	public function beginEye(eye: Int): Void {
		
	}

	public function end(): Void {
		Krom.end();
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
		var flags: Int = 0;
		if (color != null) flags |= 1;
		if (depth != null) flags |= 2;
		if (stencil != null) flags |= 4;
		Krom.clear(flags, color == null ? 0 : color.value, depth, stencil);
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {
		Krom.viewport(x, y, width, height);
	}

	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		vertexBuffer.set(0);
	}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
		Krom.setVertexBuffers(vertexBuffers);
	}

	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		indexBuffer.set();
	}

	public function setCubeMap(unit: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		Krom.setTexture(unit, cubeMap);
	}
	
	public function setCubeMapDepth(unit: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		Krom.setTextureDepth(unit, cubeMap);
	}

	public function setTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		Krom.setTexture(unit, texture);
	}
	
	public function setTextureDepth(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		Krom.setTextureDepth(unit, texture);
	}
	
	public function setTextureArray(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
	
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {

	}

	public function setImageTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		Krom.setImageTexture(unit, texture);
	}

	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		Krom.setTextureParameters(texunit, uAddressing.getIndex(), vAddressing.getIndex(), minificationFilter.getIndex(), magnificationFilter.getIndex(), mipmapFilter.getIndex());
	}

	public function setTexture3DParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		Krom.setTexture3DParameters(texunit, uAddressing.getIndex(), vAddressing.getIndex(), wAddressing.getIndex(), minificationFilter.getIndex(), magnificationFilter.getIndex(), mipmapFilter.getIndex());
	}

	public function setPipeline(pipeline: PipelineState): Void {
		pipeline.set();
	}

	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		Krom.setBool(location, value);
	}

	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		Krom.setInt(location, value);
	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: Float): Void {
		Krom.setFloat(location, value);
	}

	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float): Void {
		Krom.setFloat2(location, value1, value2);
	}

	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		Krom.setFloat3(location, value1, value2, value3);
	}

	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void {
		Krom.setFloat4(location, value1, value2, value3, value4);
	}

	public function setFloats(location: kha.graphics4.ConstantLocation, values: Vector<FastFloat>): Void {
		var vals = new kha.arrays.Float32Array(values.length);
		for (i in 0...values.length) vals.set(i, values[i]);
		Krom.setFloats(location, vals);
	}

	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		Krom.setFloat2(location, value.x, value.y);
	}

	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		Krom.setFloat3(location, value.x, value.y, value.z);
	}

	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		Krom.setFloat4(location, value.x, value.y, value.z, value.w);
	}

	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		Krom.setMatrix(location, matrix);
	}

	public inline function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: FastMatrix3): Void {
		Krom.setMatrix3(location, matrix);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		Krom.drawIndexedVertices(start, count);
	}

	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {
		Krom.drawIndexedVerticesInstanced(instanceCount, start, count);
	}

	public function instancedRenderingAvailable(): Bool {
		return false;
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		Krom.scissor(x, y, width, height);
	}

	public function disableScissor(): Void {
		Krom.disableScissor();
	}

	public function renderTargetsInvertedY(): Bool {
		return Krom.renderTargetsInvertedY();
	}
}
