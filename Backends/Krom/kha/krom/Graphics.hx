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
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;

class Graphics implements kha.graphics4.Graphics {
	public function new(renderTarget: Image = null) {

	}

	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {

	}

	public function end(): Void {

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
        Krom.clear();
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {

	}

	public function setDepthMode(write: Bool, mode: CompareMode): Void {

	}

	private static function getBlendFunc(op: BlendingFactor): Int {
        return 0;
	}

	private function setBlendingMode(source: BlendingFactor, destination: BlendingFactor): Void {

	}

	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
        vertexBuffer.set(0);
	}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {

	}

	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
        indexBuffer.set();
	}

	public function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap {
		return null;
	}

	public function setTexture(stage: kha.graphics4.TextureUnit, texture: kha.Image): Void {

	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {

	}

	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {

	}

	public function setCullMode(mode: CullMode): Void {

	}

	public function setPipeline(pipeline: PipelineState): Void {
        pipeline.set();
	}

	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {

	}

	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {

	}

	public function setFloat(location: kha.graphics4.ConstantLocation, value: Float): Void {

	}

	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float): Void {

	}

	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {

	}

	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void {

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

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
        Krom.drawIndexedVertices();
	}

	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {

	}

	public function instancedRenderingAvailable(): Bool {
		return false;
	}

	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {

	}

	inline function convertStencilAction(action: StencilAction) {

	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {

	}

	public function disableScissor(): Void {

	}

	public function renderTargetsInvertedY(): Bool {
		return true;
	}
}
