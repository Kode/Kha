package kha.js.graphics4;

import kha.graphics4.StencilValue;
import kha.arrays.Float32Array;
import js.html.webgl.GL;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.CubeMap;
import kha.graphics4.CullMode;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.PipelineState;
import kha.graphics4.StencilAction;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.WebGLImage;

class Graphics implements kha.graphics4.Graphics {
	var currentPipeline: PipelineState = null;
	private var depthTest: Bool = false;
	private var depthMask: Bool = false;
	private var colorMaskRed: Bool = true;
	private var colorMaskGreen: Bool = true;
	private var colorMaskBlue: Bool = true;
	private var colorMaskAlpha: Bool = true;
	private var indicesCount: Int;
	private var renderTarget: Canvas;
	private var renderTargetFrameBuffer: Dynamic;
	private var renderTargetMSAA: Dynamic;
	private var renderTargetTexture: Dynamic;
	private var isCubeMap: Bool = false;
	private var isDepthAttachment: Bool = false;
	private var instancedExtension: Dynamic;
	private var blendMinMaxExtension: Dynamic;
	private var useVertexAttributes:Int=0;

	// WebGL2 constants
	// https://www.khronos.org/registry/webgl/specs/2.0.0/
	private static inline var GL_TEXTURE_COMPARE_MODE = 0x884C;
	private static inline var GL_TEXTURE_COMPARE_FUNC = 0x884D;
	private static inline var GL_COMPARE_REF_TO_TEXTURE = 0x884E;

	public function new(renderTarget: Canvas = null) {
		this.renderTarget = renderTarget;
		init();
		if (SystemImpl.gl2) {
			instancedExtension = true;
		}
		else {
			instancedExtension = SystemImpl.gl.getExtension("ANGLE_instanced_arrays");
			blendMinMaxExtension = SystemImpl.gl.getExtension("EXT_blend_minmax");
		}
	}

	private function init() {
		if (renderTarget == null) return;
		isCubeMap = Std.is(renderTarget, CubeMap);
		if (isCubeMap) {
			var cubeMap: CubeMap = cast(renderTarget, CubeMap);
			renderTargetFrameBuffer = cubeMap.frameBuffer;
			renderTargetTexture = cubeMap.texture;
			isDepthAttachment = cubeMap.isDepthAttachment;
		}
		else {
			var image: WebGLImage = cast(renderTarget, WebGLImage);
			renderTargetFrameBuffer = image.frameBuffer;
			renderTargetMSAA=image.MSAAFrameBuffer;
			renderTargetTexture = image.texture;
		}
	}

	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		SystemImpl.gl.enable(GL.BLEND);
		SystemImpl.gl.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		if (renderTarget == null) {
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, null);
			SystemImpl.gl.viewport(0, 0, System.windowWidth(), System.windowHeight());
		}
		else {
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, renderTargetFrameBuffer);
			// if (isCubeMap) SystemImpl.gl.framebufferTexture(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_CUBE_MAP, renderTargetTexture, 0); // Layered
			SystemImpl.gl.viewport(0, 0, renderTarget.width, renderTarget.height);
			if (additionalRenderTargets != null) {
				SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, SystemImpl.drawBuffers.COLOR_ATTACHMENT0_WEBGL, GL.TEXTURE_2D, renderTargetTexture, 0);
				for (i in 0...additionalRenderTargets.length) {
					SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, SystemImpl.drawBuffers.COLOR_ATTACHMENT0_WEBGL + i + 1, GL.TEXTURE_2D, cast(additionalRenderTargets[i], WebGLImage).texture, 0);
				}
				var attachments = [SystemImpl.drawBuffers.COLOR_ATTACHMENT0_WEBGL];
				for (i in 0...additionalRenderTargets.length) {
					attachments.push(SystemImpl.drawBuffers.COLOR_ATTACHMENT0_WEBGL + i + 1);
				}
				SystemImpl.gl2 ? untyped SystemImpl.gl.drawBuffers(attachments) : SystemImpl.drawBuffers.drawBuffersWEBGL(attachments);
			}
		}
	}

	public function beginFace(face: Int): Void {
		SystemImpl.gl.enable(GL.BLEND);
		SystemImpl.gl.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, renderTargetFrameBuffer);
		SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, isDepthAttachment ? GL.DEPTH_ATTACHMENT : GL.COLOR_ATTACHMENT0, GL.TEXTURE_CUBE_MAP_POSITIVE_X + face, renderTargetTexture, 0);
		SystemImpl.gl.viewport(0, 0, renderTarget.width, renderTarget.height);
	}

	public function beginEye(eye: Int): Void {
		SystemImpl.gl.enable(GL.BLEND);
		SystemImpl.gl.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, null);
		if (eye == 0) {
			SystemImpl.gl.viewport(0, 0, Std.int(System.windowWidth() * 0.5), System.windowHeight());
		} else {
			SystemImpl.gl.viewport(Std.int(System.windowWidth() * 0.5), 0, Std.int(System.windowWidth() * 0.5), System.windowHeight());
		}
	}

	public function end(): Void {
		if (renderTargetMSAA != null) {
			untyped SystemImpl.gl.bindFramebuffer(SystemImpl.gl.READ_FRAMEBUFFER, renderTargetFrameBuffer);
			untyped SystemImpl.gl.bindFramebuffer(SystemImpl.gl.DRAW_FRAMEBUFFER, renderTargetMSAA);
			untyped SystemImpl.gl.blitFramebuffer(0, 0, renderTarget.width, renderTarget.height,
								0, 0, renderTarget.width, renderTarget.height,
								GL.COLOR_BUFFER_BIT, GL.NEAREST);
			
		}
		#if (debug || kha_debug_html5)
		var error = SystemImpl.gl.getError();
		switch (error) {
			case GL.NO_ERROR:

			case GL.INVALID_ENUM:
				trace("WebGL error: Invalid enum");
			case GL.INVALID_VALUE:
				trace("WebGL error: Invalid value");
			case GL.INVALID_OPERATION:
				trace("WebGL error: Invalid operation");
			case GL.INVALID_FRAMEBUFFER_OPERATION:
				trace("WebGL error: Invalid framebuffer operation");
			case GL.OUT_OF_MEMORY:
				trace("WebGL error: Out of memory");
			case GL.CONTEXT_LOST_WEBGL:
				trace("WebGL error: Context lost");
			default:
				trace("Unknown WebGL error");
		}
		#end
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
			SystemImpl.gl.colorMask(true, true, true, true);
			SystemImpl.gl.clearColor(color.R, color.G, color.B, color.A);
		}
		if (depth != null) {
			clearMask |= GL.DEPTH_BUFFER_BIT;
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			SystemImpl.gl.depthMask(true);
			SystemImpl.gl.clearDepth(depth);
		}
		if (stencil != null) {
			clearMask |= GL.STENCIL_BUFFER_BIT;
			SystemImpl.gl.enable(GL.STENCIL_TEST);
			SystemImpl.gl.stencilMask(0xff);
			SystemImpl.gl.clearStencil(stencil);
		}
		SystemImpl.gl.clear(clearMask);
		SystemImpl.gl.colorMask(colorMaskRed, colorMaskGreen, colorMaskBlue, colorMaskAlpha);
		if (depthTest) {
			SystemImpl.gl.enable(GL.DEPTH_TEST);
		}
		else {
			SystemImpl.gl.disable(GL.DEPTH_TEST);
		}
		SystemImpl.gl.depthMask(depthMask);
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {
		if (renderTarget == null) {
			SystemImpl.gl.viewport(x, System.windowHeight(0) - y - height, width, height);
		}
		else {
			SystemImpl.gl.viewport(x, y, width, height);
		}
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		SystemImpl.gl.enable(GL.SCISSOR_TEST);
		if (renderTarget == null) {
			SystemImpl.gl.scissor(x, System.windowHeight(0) - y - height, width, height);
		}
		else {
			SystemImpl.gl.scissor(x, y, width, height);
		}
	}

	public function disableScissor(): Void {
		SystemImpl.gl.disable(GL.SCISSOR_TEST);
	}

	public function setDepthMode(write: Bool, mode: CompareMode): Void {
		switch (mode) {
		case Always:
			write ? SystemImpl.gl.enable(GL.DEPTH_TEST) : SystemImpl.gl.disable(GL.DEPTH_TEST);
			depthTest = write;
			SystemImpl.gl.depthFunc(GL.ALWAYS);
		case Never:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			depthTest = true;
			SystemImpl.gl.depthFunc(GL.NEVER);
		case Equal:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			depthTest = true;
			SystemImpl.gl.depthFunc(GL.EQUAL);
		case NotEqual:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			depthTest = true;
			SystemImpl.gl.depthFunc(GL.NOTEQUAL);
		case Less:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			depthTest = true;
			SystemImpl.gl.depthFunc(GL.LESS);
		case LessEqual:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			depthTest = true;
			SystemImpl.gl.depthFunc(GL.LEQUAL);
		case Greater:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			depthTest = true;
			SystemImpl.gl.depthFunc(GL.GREATER);
		case GreaterEqual:
			SystemImpl.gl.enable(GL.DEPTH_TEST);
			depthTest = true;
			SystemImpl.gl.depthFunc(GL.GEQUAL);
		}
		SystemImpl.gl.depthMask(write);
		depthMask = write;
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
		useVertexAttributes =cast(vertexBuffer, VertexBuffer).set(0);
	}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
		var offset: Int = 0;
		for (vertexBuffer in vertexBuffers) {
			offset += cast(vertexBuffer, VertexBuffer).set(offset);
		}
		useVertexAttributes=offset;
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

	public function setTextureArray(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		//not implemented yet.
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

	public function setImageTexture(unit: kha.graphics4.TextureUnit, texture: kha.Image): Void {

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

	public function setTexture3DParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {

	}

	public function setTextureCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool) {
		if (enabled) {
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE);
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL.LEQUAL);
		}
		else {
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL.NONE);
		}
	}

	public function setCubeMapCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool) {
		if (enabled) {
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE);
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL_TEXTURE_COMPARE_FUNC, GL.LEQUAL);
		}
		else {
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL_TEXTURE_COMPARE_MODE, GL.NONE);
		}
	}

	public function setCubeMap(stage: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		if (cubeMap == null) {
			SystemImpl.gl.activeTexture(GL.TEXTURE0 + cast(stage, TextureUnit).value);
			SystemImpl.gl.bindTexture(GL.TEXTURE_CUBE_MAP, null);
		}
		else {
			cubeMap.set(cast(stage, TextureUnit).value);
		}
	}

	public function setCubeMapDepth(stage: kha.graphics4.TextureUnit, cubeMap: kha.graphics4.CubeMap): Void {
		cubeMap.setDepth(cast(stage, TextureUnit).value);
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
		currentPipeline = pipe;
		pipe.set();
		colorMaskRed = pipe.colorWriteMaskRed;
		colorMaskGreen = pipe.colorWriteMaskGreen;
		colorMaskBlue = pipe.colorWriteMaskBlue;
		colorMaskAlpha = pipe.colorWriteMaskAlpha;
	}

	public function setStencilReferenceValue(value: Int): Void {
		SystemImpl.gl.stencilFunc(convertCompareMode(currentPipeline.stencilMode), value, currentPipeline.stencilReadMask);
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

	public function setFloats(location: kha.graphics4.ConstantLocation, values: Float32Array): Void {
		var webglLocation = cast(location, ConstantLocation);
		switch (webglLocation.type) {
			case GL.FLOAT_VEC2:
				SystemImpl.gl.uniform2fv(webglLocation.value, cast values);
			case GL.FLOAT_VEC3:
				SystemImpl.gl.uniform3fv(webglLocation.value, cast values);
			case GL.FLOAT_VEC4:
				SystemImpl.gl.uniform4fv(webglLocation.value, cast values);
			case GL.FLOAT_MAT4:
				SystemImpl.gl.uniformMatrix4fv(webglLocation.value,false,cast values);
			default:
				SystemImpl.gl.uniform1fv(webglLocation.value, cast values);
		}
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

	private var matrixCache = new Float32Array(16);

	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		matrixCache[ 0] = matrix._00; matrixCache[ 1] = matrix._01; matrixCache[ 2] = matrix._02; matrixCache[ 3] = matrix._03;
		matrixCache[ 4] = matrix._10; matrixCache[ 5] = matrix._11; matrixCache[ 6] = matrix._12; matrixCache[ 7] = matrix._13;
		matrixCache[ 8] = matrix._20; matrixCache[ 9] = matrix._21; matrixCache[10] = matrix._22; matrixCache[11] = matrix._23;
		matrixCache[12] = matrix._30; matrixCache[13] = matrix._31; matrixCache[14] = matrix._32; matrixCache[15] = matrix._33;
		SystemImpl.gl.uniformMatrix4fv(cast(location, ConstantLocation).value, false, cast matrixCache);
	}

	private var matrix3Cache = new Float32Array(9);

	public inline function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: FastMatrix3): Void {
		matrix3Cache[0] = matrix._00; matrix3Cache[1] = matrix._01; matrix3Cache[2] = matrix._02;
		matrix3Cache[3] = matrix._10; matrix3Cache[4] = matrix._11; matrix3Cache[5] = matrix._12;
		matrix3Cache[6] = matrix._20; matrix3Cache[7] = matrix._21; matrix3Cache[8] = matrix._22;
		SystemImpl.gl.uniformMatrix3fv(cast(location, ConstantLocation).value, false, cast matrix3Cache);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		var type = SystemImpl.elementIndexUint == null ? GL.UNSIGNED_SHORT : GL.UNSIGNED_INT;
		var size = type == GL.UNSIGNED_SHORT ? 2 : 4;
		SystemImpl.gl.drawElements(GL.TRIANGLES, count == -1 ? indicesCount : count, type, start * size);
		for(i in 0...useVertexAttributes){
			SystemImpl.gl.disableVertexAttribArray(i);
		}
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

	function convertCompareMode(compareMode: CompareMode) {
		switch (compareMode) {
			case Always:
				return GL.ALWAYS;
			case Equal:
				return GL.EQUAL;
			case Greater:
				return GL.GREATER;
			case GreaterEqual:
				return GL.GEQUAL;
			case Less:
				return GL.LESS;
			case LessEqual:
				return GL.LEQUAL;
			case Never:
				return GL.NEVER;
			case NotEqual:
				return GL.NOTEQUAL;
		}
	}

	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: StencilValue, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		if (compareMode == CompareMode.Always && bothPass == StencilAction.Keep
			&& depthFail == StencilAction.Keep && stencilFail == StencilAction.Keep) {
				SystemImpl.gl.disable(GL.STENCIL_TEST);
			}
		else {
			SystemImpl.gl.enable(GL.STENCIL_TEST);
			var stencilFunc = convertCompareMode(compareMode);
			SystemImpl.gl.stencilMask(writeMask);
			SystemImpl.gl.stencilOp(convertStencilAction(stencilFail), convertStencilAction(depthFail), convertStencilAction(bothPass));
			switch (referenceValue) {
				case Static(value):
					SystemImpl.gl.stencilFunc(stencilFunc, value, readMask);
				case Dynamic:
					SystemImpl.gl.stencilFunc(stencilFunc, 0, readMask);
			}
		}
	}

	public function drawIndexedVerticesInstanced(instanceCount : Int, start: Int = 0, count: Int = -1) {
		if (instancedRenderingAvailable()) {
			var type = SystemImpl.elementIndexUint == null ? GL.UNSIGNED_SHORT : GL.UNSIGNED_INT;
			var typeSize = SystemImpl.elementIndexUint == null ? 2 : 4;
			if (SystemImpl.gl2) {
				untyped SystemImpl.gl.drawElementsInstanced(GL.TRIANGLES, count == -1 ? indicesCount : count, type, start * typeSize, instanceCount);
			}
			else {
				instancedExtension.drawElementsInstancedANGLE(GL.TRIANGLES, count == -1 ? indicesCount : count, type, start * typeSize, instanceCount);
			}
		}
	}

	public function instancedRenderingAvailable(): Bool {
		return instancedExtension;
	}
}
