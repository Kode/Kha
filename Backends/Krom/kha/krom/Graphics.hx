package kha.krom;

import kha.arrays.Float32Array;
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
		if (cubeMap == null) return;
		cubeMap.texture_ != null ? Krom.setTexture(unit, cubeMap.texture_) : Krom.setRenderTarget(unit, cubeMap.renderTarget_);
	}

	public function setCubeMapDepth(unit: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		if (cubeMap == null) return;
		Krom.setTextureDepth(unit, cubeMap.renderTarget_);
	}

	public function setTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		texture.texture_ != null ? Krom.setTexture(unit, texture.texture_) : Krom.setRenderTarget(unit, texture.renderTarget_);
	}

	public function setTextureDepth(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		Krom.setTextureDepth(unit, texture.renderTarget_);
	}

	public function setTextureArray(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {

	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {

	}

	public function setImageTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) return;
		Krom.setImageTexture(unit, texture.texture_);
	}

	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		Krom.setTextureParameters(texunit, uAddressing, vAddressing, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public function setTexture3DParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		Krom.setTexture3DParameters(texunit, uAddressing, vAddressing, wAddressing, minificationFilter, magnificationFilter, mipmapFilter);
	}

	public function setTextureCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool): Void {
		Krom.setTextureCompareMode(texunit, enabled);
	}

	public function setCubeMapCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool): Void {
		Krom.setCubeMapCompareMode(texunit, enabled);
	}

	public function setPipeline(pipeline: PipelineState): Void {
		pipeline.set();
	}

	public function setStencilReferenceValue(value: Int): Void {

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

	public function setFloats(location: kha.graphics4.ConstantLocation, values: Float32Array): Void {
		Krom.setFloats(location, values.buffer);
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

	static var mat = new kha.arrays.Float32Array(16);
	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		mat[0] = matrix._00; mat[1] = matrix._01; mat[2] = matrix._02; mat[3] = matrix._03;
		mat[4] = matrix._10; mat[5] = matrix._11; mat[6] = matrix._12; mat[7] = matrix._13;
		mat[8] = matrix._20; mat[9] = matrix._21; mat[10] = matrix._22; mat[11] = matrix._23;
		mat[12] = matrix._30; mat[13] = matrix._31; mat[14] = matrix._32; mat[15] = matrix._33;
		Krom.setMatrix(location, mat.buffer);
	}

	public inline function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: FastMatrix3): Void {
		mat[0] = matrix._00; mat[1] = matrix._01; mat[2] = matrix._02;
		mat[3] = matrix._10; mat[4] = matrix._11; mat[5] = matrix._12;
		mat[6] = matrix._20; mat[7] = matrix._21; mat[8] = matrix._22;
		Krom.setMatrix3(location, mat.buffer);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		Krom.drawIndexedVertices(start, count);
	}

	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {
		Krom.drawIndexedVerticesInstanced(instanceCount, start, count);
	}

	public function instancedRenderingAvailable(): Bool {
		return true;
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		Krom.scissor(x, y, width, height);
	}

	public function disableScissor(): Void {
		Krom.disableScissor();
	}
}
