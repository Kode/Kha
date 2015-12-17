package kha.js.graphics4;

import haxe.ds.Vector;
import kha.Blob;
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
import kha.WebGLImage;

class Graphics implements kha.graphics4.Graphics {
	private var framebuffer: Dynamic;
	private var indicesCount: Int;
	private var renderTarget: WebGLImage;
	private var instancedExtension: Dynamic;
	
	public function new(renderTarget: WebGLImage = null) {
		this.renderTarget = renderTarget;
		instancedExtension = SystemImpl.gl.getExtension("ANGLE_instanced_arrays");
	}

	public function begin(): Void {
		SystemImpl.gl.enable(SystemImpl.gl.BLEND);
		SystemImpl.gl.blendFunc(SystemImpl.gl.SRC_ALPHA, SystemImpl.gl.ONE_MINUS_SRC_ALPHA);
		if (renderTarget == null) {
			SystemImpl.gl.bindFramebuffer(SystemImpl.gl.FRAMEBUFFER, null);
			SystemImpl.gl.viewport(0, 0, System.pixelWidth, System.pixelHeight);
		}
		else {
			SystemImpl.gl.bindFramebuffer(SystemImpl.gl.FRAMEBUFFER, renderTarget.frameBuffer);
			SystemImpl.gl.viewport(0, 0, renderTarget.width, renderTarget.height);
		}
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
		var clearMask: Int = 0;
		if (color != null) {
			clearMask |= SystemImpl.gl.COLOR_BUFFER_BIT;
			SystemImpl.gl.clearColor(color.R, color.G, color.B, color.A);
		}
		if (depth != null) {
			clearMask |= SystemImpl.gl.DEPTH_BUFFER_BIT;
			SystemImpl.gl.clearDepth(depth);
		}
		if (stencil != null) {
			clearMask |= SystemImpl.gl.STENCIL_BUFFER_BIT;
		}
		SystemImpl.gl.clear(clearMask);
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void{
		SystemImpl.gl.viewport(x,y,width,height);
	}
	
	public function setDepthMode(write: Bool, mode: CompareMode): Void {
		switch (mode) {
		case Always:
			SystemImpl.gl.disable(SystemImpl.gl.DEPTH_TEST);
			SystemImpl.gl.depthFunc(SystemImpl.gl.ALWAYS);
		case Never:
			SystemImpl.gl.enable(SystemImpl.gl.DEPTH_TEST);
			SystemImpl.gl.depthFunc(SystemImpl.gl.NEVER);
		case Equal:
			SystemImpl.gl.enable(SystemImpl.gl.DEPTH_TEST);
			SystemImpl.gl.depthFunc(SystemImpl.gl.EQUAL);
		case NotEqual:
			SystemImpl.gl.enable(SystemImpl.gl.DEPTH_TEST);
			SystemImpl.gl.depthFunc(SystemImpl.gl.NOTEQUAL);
		case Less:
			SystemImpl.gl.enable(SystemImpl.gl.DEPTH_TEST);
			SystemImpl.gl.depthFunc(SystemImpl.gl.LESS);
		case LessEqual:
			SystemImpl.gl.enable(SystemImpl.gl.DEPTH_TEST);
			SystemImpl.gl.depthFunc(SystemImpl.gl.LEQUAL);
		case Greater:
			SystemImpl.gl.enable(SystemImpl.gl.DEPTH_TEST);
			SystemImpl.gl.depthFunc(SystemImpl.gl.GREATER);
		case GreaterEqual:
			SystemImpl.gl.enable(SystemImpl.gl.DEPTH_TEST);
			SystemImpl.gl.depthFunc(SystemImpl.gl.GEQUAL);
		}
		SystemImpl.gl.depthMask(write);
	}
	
	private function getBlendFunc(op: BlendingOperation): Int {
		switch (op) {
		case BlendZero, Undefined:
			return SystemImpl.gl.ZERO;
		case BlendOne:
			return SystemImpl.gl.ONE;
		case SourceAlpha:
			return SystemImpl.gl.SRC_ALPHA;
		case DestinationAlpha:
			return SystemImpl.gl.DST_ALPHA;
		case InverseSourceAlpha:
			return SystemImpl.gl.ONE_MINUS_SRC_ALPHA;
		case InverseDestinationAlpha:
			return SystemImpl.gl.ONE_MINUS_DST_ALPHA;
		}
	}
	
	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		if (source == BlendOne && destination == BlendZero) {
			SystemImpl.gl.disable(SystemImpl.gl.BLEND);
		}
		else {
			SystemImpl.gl.enable(SystemImpl.gl.BLEND);
			SystemImpl.gl.blendFunc(getBlendFunc(source), getBlendFunc(destination));
		}
	}
	
	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
		return new VertexBuffer(vertexCount, structure, usage);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set(0);
	}
	
	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
		var offset: Int = 0;
		for (vertexBuffer in vertexBuffers) {
			offset += cast(vertexBuffer, VertexBuffer).set(offset);
		}
	}
	
	public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics4.IndexBuffer {
		return new IndexBuffer(indexCount, usage);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		indicesCount = indexBuffer.count();
		cast(indexBuffer, IndexBuffer).set();
	}
	
	//public function maxTextureSize(): Int {
	//	return Sys.gl == null ? 8192 : Sys.gl.getParameter(Sys.gl.MAX_TEXTURE_SIZE);
	//}
	
	//public function supportsNonPow2Textures(): Bool {
	//	return false;
	//}
	
	public function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap {
		return null;
	}
	
	public function setTexture(stage: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) {
			SystemImpl.gl.activeTexture(SystemImpl.gl.TEXTURE0 + cast(stage, TextureUnit).value);
			SystemImpl.gl.bindTexture(SystemImpl.gl.TEXTURE_2D, null);
		}
		else {
			cast(texture, WebGLImage).set(cast(stage, TextureUnit).value);
		}
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {
		if (texture == null) {
			SystemImpl.gl.activeTexture(SystemImpl.gl.TEXTURE0 + cast(unit, TextureUnit).value);
			SystemImpl.gl.bindTexture(SystemImpl.gl.TEXTURE_2D, null);
		}
		else {
			cast(cast(texture, kha.js.Video).texture, WebGLImage).set(cast(unit, TextureUnit).value);
		}
	}
	
	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		SystemImpl.gl.activeTexture(SystemImpl.gl.TEXTURE0 + cast(texunit, TextureUnit).value);
		
		switch (uAddressing) {
		case Clamp:
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_S, SystemImpl.gl.CLAMP_TO_EDGE);
		case Repeat:
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_S, SystemImpl.gl.REPEAT);
		case Mirror:
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_S, SystemImpl.gl.MIRRORED_REPEAT);
		}
		
		switch (vAddressing) {
		case Clamp:
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_T, SystemImpl.gl.CLAMP_TO_EDGE);
		case Repeat:
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_T, SystemImpl.gl.REPEAT);
		case Mirror:
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_T, SystemImpl.gl.MIRRORED_REPEAT);
		}
	
		switch (minificationFilter) {
		case PointFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MIN_FILTER, SystemImpl.gl.NEAREST);
			case PointMipFilter:
				SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MIN_FILTER, SystemImpl.gl.NEAREST_MIPMAP_NEAREST);
			case LinearMipFilter:
				SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MIN_FILTER, SystemImpl.gl.NEAREST_MIPMAP_LINEAR);
			}
		case LinearFilter, AnisotropicFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MIN_FILTER, SystemImpl.gl.LINEAR);
			case PointMipFilter:
				SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MIN_FILTER, SystemImpl.gl.LINEAR_MIPMAP_NEAREST);
			case LinearMipFilter:
				SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MIN_FILTER, SystemImpl.gl.LINEAR_MIPMAP_LINEAR);
			}
		}
		
		switch (magnificationFilter) {
			case PointFilter:
				SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MAG_FILTER, SystemImpl.gl.NEAREST);
			case LinearFilter, AnisotropicFilter:
				SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MAG_FILTER, SystemImpl.gl.LINEAR);
		}
	}
	
	public function setCullMode(mode: CullMode): Void {
		switch (mode) {
		case None:
			SystemImpl.gl.disable(SystemImpl.gl.CULL_FACE);
		case Clockwise:
			SystemImpl.gl.enable(SystemImpl.gl.CULL_FACE);
			SystemImpl.gl.cullFace(SystemImpl.gl.FRONT);
		case CounterClockwise:
			SystemImpl.gl.enable(SystemImpl.gl.CULL_FACE);
			SystemImpl.gl.cullFace(SystemImpl.gl.BACK);
		}
	}

	public function setPipeline(pipe: PipelineState): Void {
		setCullMode(pipe.cullMode);
		setDepthMode(pipe.depthWrite, pipe.depthMode);
		setStencilParameters(pipe.stencilMode, pipe.stencilBothPass, pipe.stencilDepthFail, pipe.stencilFail, pipe.stencilReferenceValue, pipe.stencilReferenceValue, pipe.stencilWriteMask);
		setBlendingMode(pipe.blendSource, pipe.blendDestination);
		pipe.set();
	}
	
	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		SystemImpl.gl.uniform1i(cast(location, ConstantLocation).value, value ? 1 : 0);
	}
	
	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		SystemImpl.gl.uniform1i(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat(location: kha.graphics4.ConstantLocation, value: FastFloat): Void {
		SystemImpl.gl.uniform1f(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		SystemImpl.gl.uniform2f(cast(location, ConstantLocation).value, value1, value2);
	}
	
	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		SystemImpl.gl.uniform3f(cast(location, ConstantLocation).value, value1, value2, value3);
	}
	
	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		SystemImpl.gl.uniform4f(cast(location, ConstantLocation).value, value1, value2, value3, value4);
	}
	
	public function setFloats(location: kha.graphics4.ConstantLocation, values: Vector<FastFloat>): Void {
		SystemImpl.gl.uniform1fv(cast(location, ConstantLocation).value, values);
	}
	
	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		SystemImpl.gl.uniform2f(cast(location, ConstantLocation).value, value.x, value.y);
	}
	
	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		SystemImpl.gl.uniform3f(cast(location, ConstantLocation).value, value.x, value.y, value.z);
	}
	
	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		SystemImpl.gl.uniform4f(cast(location, ConstantLocation).value, value.x, value.y, value.z, value.w);
	}
	
	private var matrixCache = new Vector<Float>(16);
	
	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		matrixCache[ 0] = matrix._00; matrixCache[ 1] = matrix._01; matrixCache[ 2] = matrix._02; matrixCache[ 3] = matrix._03;
		matrixCache[ 4] = matrix._10; matrixCache[ 5] = matrix._11; matrixCache[ 6] = matrix._12; matrixCache[ 7] = matrix._13;
		matrixCache[ 8] = matrix._20; matrixCache[ 9] = matrix._21; matrixCache[10] = matrix._22; matrixCache[11] = matrix._23;
		matrixCache[12] = matrix._30; matrixCache[13] = matrix._31; matrixCache[14] = matrix._32; matrixCache[15] = matrix._33;
		SystemImpl.gl.uniformMatrix4fv(cast(location, ConstantLocation).value, false, matrixCache.toData());
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		SystemImpl.gl.drawElements(SystemImpl.gl.TRIANGLES, count == -1 ? indicesCount : count, SystemImpl.gl.UNSIGNED_SHORT, start * 2);
	}
	
	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		SystemImpl.gl.enable(SystemImpl.gl.SCISSOR_TEST);
		var h: Int = renderTarget == null ? System.pixelHeight : renderTarget.height;
		SystemImpl.gl.scissor(x, h - y - height, width, height);
	}
	
	public function disableScissor(): Void {
		SystemImpl.gl.disable(SystemImpl.gl.SCISSOR_TEST);
	}
	
	public function renderTargetsInvertedY(): Bool {
		return true;
	}
	
	public function drawIndexedVerticesInstanced(instanceCount : Int, start: Int = 0, count: Int = -1) {
		if (instancedRenderingAvailable()) {
			instancedExtension.drawElementsInstancedANGLE(SystemImpl.gl.TRIANGLES, count == -1 ? indicesCount : count, SystemImpl.gl.UNSIGNED_SHORT, start * 2, instanceCount);
		}
	}
	
	public function instancedRenderingAvailable(): Bool {
		return instancedExtension;
	}
}
