package kha.js.graphics4;

import haxe.ds.Vector;
import js.html.webgl.GL;
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
import kha.WebGLImage;

class Graphics implements kha.graphics4.Graphics {
	private var framebuffer: Dynamic;
	private var indicesCount: Int;
	private var renderTarget: WebGLImage;
	private var instancedExtension: Dynamic;
	private var blendMinMaxExtension: Dynamic;

	public function new(renderTarget: WebGLImage = null) {
		this.renderTarget = renderTarget;
		instancedExtension = SystemImpl.gl.getExtension("ANGLE_instanced_arrays");
		blendMinMaxExtension = SystemImpl.gl.getExtension("EXT_blend_minmax");
	}

	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		SystemImpl.gl.enable(GL.BLEND);
		SystemImpl.gl.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		if (renderTarget == null) {
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, null);
			SystemImpl.gl.viewport(0, 0, System.windowWidth(), System.windowHeight());
		}
		else {
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, renderTarget.frameBuffer);
			SystemImpl.gl.viewport(0, 0, renderTarget.width, renderTarget.height);
			if (additionalRenderTargets != null) {
				SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, SystemImpl.drawBuffers.COLOR_ATTACHMENT0_WEBGL, GL.TEXTURE_2D, renderTarget.texture, 0);
				for (i in 0...additionalRenderTargets.length) {
					SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, SystemImpl.drawBuffers.COLOR_ATTACHMENT0_WEBGL + i + 1, GL.TEXTURE_2D, cast(additionalRenderTargets[i], WebGLImage).texture, 0);
				}
				var attachments = [SystemImpl.drawBuffers.COLOR_ATTACHMENT0_WEBGL];
				for (i in 0...additionalRenderTargets.length) {
					attachments.push(SystemImpl.drawBuffers.COLOR_ATTACHMENT0_WEBGL + i + 1);
				}
				SystemImpl.drawBuffers.drawBuffersWEBGL(attachments);
			}
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
			clearMask |= GL.COLOR_BUFFER_BIT;
			SystemImpl.gl.clearColor(color.R, color.G, color.B, color.A);
		}
		if (depth != null) {
			clearMask |= GL.DEPTH_BUFFER_BIT;
			SystemImpl.gl.clearDepth(depth);
		}
		if (stencil != null) {
			clearMask |= GL.STENCIL_BUFFER_BIT;
			SystemImpl.gl.enable(GL.STENCIL_TEST);
			SystemImpl.gl.stencilMask(0xff);
			SystemImpl.gl.clearStencil(stencil);
		}
		SystemImpl.gl.clear(clearMask);
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void{
		var h: Int = renderTarget == null ? System.windowHeight(0) : renderTarget.height;
		SystemImpl.gl.viewport(x, h - y - height, width, height);
	}

	public function setDepthMode(write: Bool, mode: CompareMode): Void {
		switch (mode) {
		case Always:
			write ? SystemImpl.gl.enable(GL.DEPTH_TEST) : SystemImpl.gl.disable(GL.DEPTH_TEST);
			SystemImpl.gl.depthFunc(GL.ALWAYS);
		case Never:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			SystemImpl.gl.depthFunc(GL.NEVER);
		case Equal:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			SystemImpl.gl.depthFunc(GL.EQUAL);
		case NotEqual:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			SystemImpl.gl.depthFunc(GL.NOTEQUAL);
		case Less:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			SystemImpl.gl.depthFunc(GL.LESS);
		case LessEqual:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			SystemImpl.gl.depthFunc(GL.LEQUAL);
		case Greater:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			SystemImpl.gl.depthFunc(GL.GREATER);
		case GreaterEqual:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			SystemImpl.gl.depthFunc(GL.GEQUAL);
		}
		SystemImpl.gl.depthMask(write);
	}

	private static function getBlendFunc(factor: BlendingFactor): Int {
		switch (factor) {
		case BlendZero, Undefined:
			return GL.ZERO;
		case BlendOne:
			return GL.ONE;
		case SourceAlpha:
			return GL.SRC_ALPHA;
		case DestinationAlpha:
			return GL.DST_ALPHA;
		case InverseSourceAlpha:
			return GL.ONE_MINUS_SRC_ALPHA;
		case InverseDestinationAlpha:
			return GL.ONE_MINUS_DST_ALPHA;
		case SourceColor:
			return GL.SRC_COLOR;
		case DestinationColor:
			return GL.DST_COLOR;
		case InverseSourceColor:
			return GL.ONE_MINUS_SRC_COLOR;
		case InverseDestinationColor:
			return GL.ONE_MINUS_DST_COLOR;
		}
	}

	private static function getBlendOp(op: BlendingOperation): Int {
		switch (op) {
		case Add:
			return GL.FUNC_ADD;
		case Subtract:
			return GL.FUNC_SUBTRACT;
		case ReverseSubtract:
			return GL.FUNC_REVERSE_SUBTRACT;
		case Min:
			return 0x8007;
		case Max:
			return 0x8008;
		}
	}
	
	public function setBlendingMode(source: BlendingFactor, destination: BlendingFactor, operation: BlendingOperation,
		alphaSource: BlendingFactor, alphaDestination: BlendingFactor, alphaOperation: BlendingOperation): Void {
		if (source == BlendOne && destination == BlendZero) {
			SystemImpl.gl.disable(GL.BLEND);
		}
		else {
			SystemImpl.gl.enable(GL.BLEND);
			SystemImpl.gl.blendFuncSeparate(getBlendFunc(source), getBlendFunc(destination), getBlendFunc(alphaSource), getBlendFunc(alphaDestination));
			SystemImpl.gl.blendEquationSeparate(getBlendOp(operation), getBlendOp(alphaOperation));
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
			SystemImpl.gl.activeTexture(GL.TEXTURE0 + cast(stage, TextureUnit).value);
			SystemImpl.gl.bindTexture(GL.TEXTURE_2D, null);
		}
		else {
			cast(texture, WebGLImage).set(cast(stage, TextureUnit).value);
		}
	}
	
	public function setTextureDepth(stage: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		cast(texture, WebGLImage).setDepth(cast(stage, TextureUnit).value);
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {
		if (texture == null) {
			SystemImpl.gl.activeTexture(GL.TEXTURE0 + cast(unit, TextureUnit).value);
			SystemImpl.gl.bindTexture(GL.TEXTURE_2D, null);
		}
		else {
			cast(cast(texture, kha.js.Video).texture, WebGLImage).set(cast(unit, TextureUnit).value);
		}
	}

	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		SystemImpl.gl.activeTexture(GL.TEXTURE0 + cast(texunit, TextureUnit).value);

		switch (uAddressing) {
		case Clamp:
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		case Repeat:
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
		case Mirror:
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.MIRRORED_REPEAT);
		}

		switch (vAddressing) {
		case Clamp:
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		case Repeat:
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
		case Mirror:
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.MIRRORED_REPEAT);
		}

		switch (minificationFilter) {
		case PointFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			case PointMipFilter:
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST_MIPMAP_NEAREST);
			case LinearMipFilter:
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST_MIPMAP_LINEAR);
			}
		case LinearFilter, AnisotropicFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			case PointMipFilter:
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_NEAREST);
			case LinearMipFilter:
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
			}
			if (minificationFilter == AnisotropicFilter) {
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, SystemImpl.anisotropicFilter.TEXTURE_MAX_ANISOTROPY_EXT, 4);
			}
		}

		switch (magnificationFilter) {
			case PointFilter:
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			case LinearFilter, AnisotropicFilter:
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		}
	}

	public function setCullMode(mode: CullMode): Void {
		switch (mode) {
		case None:
			SystemImpl.gl.disable(GL.CULL_FACE);
		case Clockwise:
			SystemImpl.gl.enable(GL.CULL_FACE);
			SystemImpl.gl.cullFace(GL.BACK);
		case CounterClockwise:
			SystemImpl.gl.enable(GL.CULL_FACE);
			SystemImpl.gl.cullFace(GL.FRONT);
		}
	}

	public function setPipeline(pipe: PipelineState): Void {
		setCullMode(pipe.cullMode);
		setDepthMode(pipe.depthWrite, pipe.depthMode);
		setStencilParameters(pipe.stencilMode, pipe.stencilBothPass, pipe.stencilDepthFail, pipe.stencilFail, pipe.stencilReferenceValue, pipe.stencilReadMask, pipe.stencilWriteMask);
		setBlendingMode(pipe.blendSource, pipe.blendDestination, pipe.blendOperation, pipe.alphaBlendSource, pipe.alphaBlendDestination, pipe.alphaBlendOperation);
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
		SystemImpl.gl.uniform1fv(cast(location, ConstantLocation).value, cast values);
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
		SystemImpl.gl.drawElements(GL.TRIANGLES, count == -1 ? indicesCount : count, GL.UNSIGNED_SHORT, start * 2);
	}

	private function convertStencilAction(action: StencilAction) {
		switch (action) {
			case StencilAction.Decrement:
				return GL.DECR;
			case StencilAction.DecrementWrap:
				return GL.DECR_WRAP;
			case StencilAction.Increment:
				return GL.INCR;
			case StencilAction.IncrementWrap:
				return GL.INCR_WRAP;
			case StencilAction.Invert:
				return GL.INVERT;
			case StencilAction.Keep:
				return GL.KEEP;
			case StencilAction.Replace:
				return GL.REPLACE;
			case StencilAction.Zero:
				return GL.ZERO;
		}
	}

	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		if (compareMode == CompareMode.Always && bothPass == StencilAction.Keep
			&& depthFail == StencilAction.Keep && stencilFail == StencilAction.Keep) {
				SystemImpl.gl.disable(GL.STENCIL_TEST);
			}
		else {
			SystemImpl.gl.enable(GL.STENCIL_TEST);
			var stencilFunc = 0;
			switch (compareMode) {
				case CompareMode.Always:
					stencilFunc = GL.ALWAYS;
				case CompareMode.Equal:
					stencilFunc = GL.EQUAL;
				case CompareMode.Greater:
					stencilFunc = GL.GREATER;
				case CompareMode.GreaterEqual:
					stencilFunc = GL.GEQUAL;
				case CompareMode.Less:
					stencilFunc = GL.LESS;
				case CompareMode.LessEqual:
					stencilFunc = GL.LEQUAL;
				case CompareMode.Never:
					stencilFunc = GL.NEVER;
				case CompareMode.NotEqual:
					stencilFunc = GL.NOTEQUAL;
			}
			SystemImpl.gl.stencilMask(writeMask);
			SystemImpl.gl.stencilOp(convertStencilAction(stencilFail), convertStencilAction(depthFail), convertStencilAction(bothPass));
			SystemImpl.gl.stencilFunc(stencilFunc, referenceValue, readMask);
		}
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		SystemImpl.gl.enable(GL.SCISSOR_TEST);
		var h: Int = renderTarget == null ? System.windowHeight(0) : renderTarget.height;
		SystemImpl.gl.scissor(x, h - y - height, width, height);
	}

	public function disableScissor(): Void {
		SystemImpl.gl.disable(GL.SCISSOR_TEST);
	}

	public function renderTargetsInvertedY(): Bool {
		return true;
	}

	public function drawIndexedVerticesInstanced(instanceCount : Int, start: Int = 0, count: Int = -1) {
		if (instancedRenderingAvailable()) {
			instancedExtension.drawElementsInstancedANGLE(GL.TRIANGLES, count == -1 ? indicesCount : count, GL.UNSIGNED_SHORT, start * 2, instanceCount);
		}
	}

	public function instancedRenderingAvailable(): Bool {
		return instancedExtension;
	}
}
