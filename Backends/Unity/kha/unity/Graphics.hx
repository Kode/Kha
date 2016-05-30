package kha.unity;

import haxe.ds.Vector;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CubeMap;
import kha.graphics4.CullMode;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.StencilAction;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.Image;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import unityEngine.GL;
import unityEngine.Matrix4x4;
import unityEngine.RenderTexture;

class Graphics implements kha.graphics4.Graphics {
	private var vertexBuffer: VertexBuffer;
	private var indexBuffer: IndexBuffer;
	private var pipeline: PipelineState;
	private var target: Image;

	public function new(target: Image) {
		this.target = target;
	}

	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		if (target == null) {
			RenderTexture.active = null;
		}
		else {
			RenderTexture.active = cast target.texture;
			//setViewport(target.width, target.height);
		}
	}

	@:functionCode('UnityEngine.GL.Viewport(new UnityEngine.Rect(0, 0, w, h));')
	private function setViewport(w: Int, h: Int): Void {

	}

	public function end(): Void {
		RenderTexture.active = null;
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
		var c = new unityEngine.Color(0, 0, 0, 0);
		if (color != null) c = new unityEngine.Color(color.R, color.G, color.B, color.A);
		GL.Clear(depth != null, color != null, c, depth != null ? depth : 0);
	}

	@:functionCode('UnityEngine.GL.Viewport(new UnityEngine.Rect(x, y, width, height));')
	public function viewport(x : Int, y : Int, width : Int, height : Int): Void{

	}

	public function setCullMode(mode: CullMode): Void {

	}

	public function setDepthMode(write: Bool, mode: CompareMode): Void {

	}

	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {

	}

	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {

	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {

	}

	public function disableScissor(): Void {

	}

	public function setVertexBuffer(vertexBuffer: VertexBuffer): Void {
		this.vertexBuffer = vertexBuffer;
	}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {

	}

	public function setIndexBuffer(indexBuffer: IndexBuffer): Void {
		this.indexBuffer = indexBuffer;
	}

	public function setTexture(unit: TextureUnit, texture: Image): Void {
		if (texture == null) return;
		pipeline.material.SetTexture(cast(unit, kha.unity.TextureUnit).name, texture.texture);
	}
	
	public function setTextureDepth(unit: TextureUnit, texture: Image): Void {
	
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {

	}

	public function setTextureParameters(texunit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {

	}

	public function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap {
		return null;
	}

	public function renderTargetsInvertedY(): Bool {
		return !UnityBackend.uvStartsAtTop();
	}

	public function setPipeline(pipeline: PipelineState): Void {
		this.pipeline = pipeline;
		var w = System.windowWidth();
		var h = System.windowHeight();
		if (target != null) {
			w = target.width;
			h = target.height;
		}
		var x = 1.0 / w;
		var y = 1.0 / h;
		pipeline.material.SetVector("dx_ViewAdjust", new unityEngine.Vector4(x, y, x, y));
	}

	public function setBool(location: ConstantLocation, value: Bool): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		pipeline.material.SetInt(loc.name, value ? 1 : 0);
	}

	public function setInt(location: ConstantLocation, value: Int): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		pipeline.material.SetInt(loc.name, value);
	}

	public function setFloat(location: ConstantLocation, value: Float): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		pipeline.material.SetFloat(loc.name, value);
	}

	public function setFloat2(location: ConstantLocation, value1: Float, value2: Float): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		pipeline.material.SetVector(loc.name, new unityEngine.Vector4(value1, value2, 0.0, 1.0));
	}

	public function setFloat3(location: ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		pipeline.material.SetVector(loc.name, new unityEngine.Vector4(value1, value2, value3, 1.0));
	}

	public function setFloat4(location: ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		pipeline.material.SetVector(loc.name, new unityEngine.Vector4(value1, value2, value3, value4));
	}

	public function setFloats(location: ConstantLocation, floats: Vector<FastFloat>): Void {

	}

	public function setVector2(location: ConstantLocation, value: FastVector2): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		pipeline.material.SetVector(loc.name, new unityEngine.Vector4(value.x, value.y, 0.0, 1.0));
	}

	public function setVector3(location: ConstantLocation, value: FastVector3): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		pipeline.material.SetVector(loc.name, new unityEngine.Vector4(value.x, value.y, value.z, 1.0));
	}

	public function setVector4(location: ConstantLocation, value: FastVector4): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		pipeline.material.SetVector(loc.name, new unityEngine.Vector4(value.x, value.y, value.z, value.w));
	}

	public function setMatrix(location: ConstantLocation, value: FastMatrix4): Void {
		var loc = cast(location, kha.unity.ConstantLocation);
		var m = unityEngine.Matrix4x4.zero;
		m.SetRow(0, new unityEngine.Vector4(value._00, value._01, value._02, value._03));
		m.SetRow(1, new unityEngine.Vector4(value._10, value._11, value._12, value._13));
		m.SetRow(2, new unityEngine.Vector4(value._20, value._21, value._22, value._23));
		m.SetRow(3, new unityEngine.Vector4(value._30, value._31, value._32, value._33));
		pipeline.material.SetMatrix(loc.name, m);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		if (count < 0) {
			vertexBuffer.mesh.triangles = indexBuffer.nativeIndices;
		}
		else {
			for (i in 0...count) {
				indexBuffer.nativeCutIndices[i] = indexBuffer.nativeIndices[i];
			}
			for (i in count...indexBuffer.nativeCutIndices.length) {
				indexBuffer.nativeCutIndices[i] = 0;
			}
			vertexBuffer.mesh.triangles = indexBuffer.nativeCutIndices;
		}
		for (i in 0...pipeline.material.passCount) {
			if (pipeline.material.SetPass(i)) {
				unityEngine.Graphics.DrawMeshNow(vertexBuffer.mesh, Matrix4x4.identity);
			}
		}
	}

	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {

	}

	public function instancedRenderingAvailable(): Bool {
		return false;
	}
}
