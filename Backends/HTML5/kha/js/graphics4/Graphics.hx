package kha.js.graphics4;

import kha.Blob;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.CubeMap;
import kha.graphics4.CullMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
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
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Rectangle;
import kha.WebGLImage;

class Graphics implements kha.graphics4.Graphics {
	private var framebuffer: Dynamic;
	private var indicesCount: Int;
	private var renderTarget: WebGLImage;
	
	public function new(webgl: Bool, renderTarget: WebGLImage = null) {
		this.renderTarget = renderTarget;
		if (webgl) {
			Sys.gl.enable(Sys.gl.BLEND);
			Sys.gl.blendFunc(Sys.gl.SRC_ALPHA, Sys.gl.ONE_MINUS_SRC_ALPHA);
			Sys.gl.viewport(0, 0, Sys.pixelWidth, Sys.pixelHeight);
		}
	}
	
	public function init(?backbufferFormat: TextureFormat, antiAliasingSamples: Int = 1): Void {
		
	}
	
	public function begin(): Void {
		if (renderTarget == null) {
			Sys.gl.bindFramebuffer(Sys.gl.FRAMEBUFFER, null);
			Sys.gl.viewport(0, 0, Sys.pixelWidth, Sys.pixelHeight);
		}
		else {
			Sys.gl.bindFramebuffer(Sys.gl.FRAMEBUFFER, renderTarget.frameBuffer);
			Sys.gl.viewport(0, 0, renderTarget.width, renderTarget.height);
		}
	}
	
	public function end(): Void {
		
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
			clearMask |= Sys.gl.COLOR_BUFFER_BIT;
			Sys.gl.clearColor(color.R, color.G, color.B, color.A);
		}
		if (depth != null) {
			clearMask |= Sys.gl.DEPTH_BUFFER_BIT;
			Sys.gl.clearDepth(depth);
		}
		if (stencil != null) {
			clearMask |= Sys.gl.STENCIL_BUFFER_BIT;
		}
		Sys.gl.clear(clearMask);
	}
	
	public function setDepthMode(write: Bool, mode: CompareMode): Void {
		switch (mode) {
		case Always:
			Sys.gl.disable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.ALWAYS);
		case Never:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.NEVER);
		case Equal:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.EQUAL);
		case NotEqual:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.NOTEQUAL);
		case Less:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.LESS);
		case LessEqual:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.LEQUAL);
		case Greater:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.GREATER);
		case GreaterEqual:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.GEQUAL);
		}
		Sys.gl.depthMask(write);
	}
	
	private function getBlendFunc(op: BlendingOperation): Int {
		switch (op) {
		case BlendZero, Undefined:
			return Sys.gl.ZERO;
		case BlendOne:
			return Sys.gl.ONE;
		case SourceAlpha:
			return Sys.gl.SRC_ALPHA;
		case DestinationAlpha:
			return Sys.gl.DST_ALPHA;
		case InverseSourceAlpha:
			return Sys.gl.ONE_MINUS_SRC_ALPHA;
		case InverseDestinationAlpha:
			return Sys.gl.ONE_MINUS_DST_ALPHA;
		}
	}
	
	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		if (source == BlendOne && destination == BlendZero) {
			Sys.gl.disable(Sys.gl.BLEND);
		}
		else {
			Sys.gl.enable(Sys.gl.BLEND);
			Sys.gl.blendFunc(getBlendFunc(source), getBlendFunc(destination));
		}
	}
	
	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
		return new VertexBuffer(vertexCount, structure, usage);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
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
			Sys.gl.activeTexture(Sys.gl.TEXTURE0 + cast(stage, TextureUnit).value);
			Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, null);
		}
		else {
			cast(texture, WebGLImage).set(cast(stage, TextureUnit).value);
		}
	}
	
	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		Sys.gl.activeTexture(Sys.gl.TEXTURE0 + cast(texunit, TextureUnit).value);
		
		switch (uAddressing) {
		case Clamp:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.CLAMP_TO_EDGE);
		case Repeat:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.REPEAT);
		case Mirror:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.MIRRORED_REPEAT);
		}
		
		switch (vAddressing) {
		case Clamp:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.CLAMP_TO_EDGE);
		case Repeat:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.REPEAT);
		case Mirror:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.MIRRORED_REPEAT);
		}
	
		switch (minificationFilter) {
		case PointFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.NEAREST);
			case PointMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.NEAREST_MIPMAP_NEAREST);
			case LinearMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.NEAREST_MIPMAP_LINEAR);
			}
		case LinearFilter, AnisotropicFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR);
			case PointMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR_MIPMAP_NEAREST);
			case LinearMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR_MIPMAP_LINEAR);
			}
		}
		
		switch (magnificationFilter) {
			case PointFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.NEAREST);
			case LinearFilter, AnisotropicFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.LINEAR);
		}
	}
	
	public function setCullMode(mode: CullMode): Void {
		switch (mode) {
		case None:
			Sys.gl.disable(Sys.gl.CULL_FACE);
		case Clockwise:
			Sys.gl.enable(Sys.gl.CULL_FACE);
			Sys.gl.cullFace(Sys.gl.FRONT);
		case CounterClockwise:
			Sys.gl.enable(Sys.gl.CULL_FACE);
			Sys.gl.cullFace(Sys.gl.BACK);
		}
	}

	public function setProgram(program: kha.graphics4.Program): Void {
		program.set();
	}
	
	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		Sys.gl.uniform1i(cast(location, ConstantLocation).value, value ? 1 : 0);
	}
	
	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		Sys.gl.uniform1i(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat(location: kha.graphics4.ConstantLocation, value: Float): Void {
		Sys.gl.uniform1f(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float): Void {
		Sys.gl.uniform2f(cast(location, ConstantLocation).value, value1, value2);
	}
	
	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		Sys.gl.uniform3f(cast(location, ConstantLocation).value, value1, value2, value3);
	}
	
	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void {
		Sys.gl.uniform4f(cast(location, ConstantLocation).value, value1, value2, value3, value4);
	}
	
	public function setFloats(location: kha.graphics4.ConstantLocation, values: Array<Float>): Void {
		Sys.gl.uniform1fv(cast(location, ConstantLocation).value, values);
	}
	
	public function setVector2(location: kha.graphics4.ConstantLocation, value: Vector2): Void {
		Sys.gl.uniform2f(cast(location, ConstantLocation).value, value.x, value.y);
	}
	
	public function setVector3(location: kha.graphics4.ConstantLocation, value: Vector3): Void {
		Sys.gl.uniform3f(cast(location, ConstantLocation).value, value.x, value.y, value.z);
	}
	
	public function setVector4(location: kha.graphics4.ConstantLocation, value: Vector4): Void {
		Sys.gl.uniform4f(cast(location, ConstantLocation).value, value.x, value.y, value.z, value.w);
	}
	
	public function setMatrix(location: kha.graphics4.ConstantLocation, matrix: Matrix4): Void {
		Sys.gl.uniformMatrix4fv(cast(location, ConstantLocation).value, false, matrix.matrix);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		Sys.gl.drawElements(Sys.gl.TRIANGLES, count == -1 ? indicesCount : count, Sys.gl.UNSIGNED_SHORT, start * 2);
	}
	
	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		
	}

	public function setScissor(rect: Rectangle): Void {
		
	}
	
	public function renderTargetsInvertedY(): Bool {
		return true;
	}
}
