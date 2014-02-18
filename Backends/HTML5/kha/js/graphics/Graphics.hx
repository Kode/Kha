package kha.js.graphics;

import kha.Blob;
import kha.graphics.BlendingOperation;
import kha.graphics.CompareMode;
import kha.graphics.CubeMap;
import kha.graphics.CullMode;
import kha.graphics.FragmentShader;
import kha.graphics.MipMapFilter;
import kha.graphics.StencilAction;
import kha.graphics.TexDir;
import kha.graphics.Texture;
import kha.graphics.TextureAddressing;
import kha.graphics.TextureFilter;
import kha.graphics.TextureFormat;
import kha.graphics.Usage;
import kha.graphics.VertexStructure;
import kha.graphics.VertexShader;
import kha.js.Image;
import kha.Rectangle;

class Graphics implements kha.graphics.Graphics {
	private var indicesCount: Int;
	
	public function new(webgl: Bool) {
		if (webgl) {
			Sys.gl.enable(Sys.gl.BLEND);
			Sys.gl.blendFunc(Sys.gl.SRC_ALPHA, Sys.gl.ONE_MINUS_SRC_ALPHA);
		}
	}
	
	public function init(?backbufferFormat: TextureFormat, antiAliasingSamples: Int = 1): Void {
		
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
		case BlendZero:
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
	
	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount, structure, usage);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount, usage);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics.IndexBuffer): Void {
		indicesCount = indexBuffer.count();
		cast(indexBuffer, IndexBuffer).set();
	}
	
	public function createTexture(width: Int, height: Int, format: TextureFormat, usage: Usage, canRead: Bool = false, levels: Int = 1): Texture {
		return new Image(width, height, format);
	}
	
	public function createRenderTargetTexture(width: Int, height: Int, format: TextureFormat, depthStencil: Bool, antiAliasingSamples: Int = 1): Texture {
		return new Image(width, height, format);
	}
	
	public function maxTextureSize(): Int {
		return Sys.gl == null ? 8192 : Sys.gl.getParameter(Sys.gl.MAX_TEXTURE_SIZE);
	}
	
	public function supportsNonPow2Textures(): Bool {
		return false;
	}
	
	public function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap {
		return null;
	}
	
	public function setTexture(stage: kha.graphics.TextureUnit, texture: kha.Image): Void {
		if (texture == null) {
			Sys.gl.activeTexture(Sys.gl.TEXTURE0 + cast(stage, TextureUnit).value);
			Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, null);
		}
		else {
			cast(texture, Image).set(cast(stage, TextureUnit).value);
		}
	}
	
	public function setTextureParameters(texunit: kha.graphics.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
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
	
	public function createVertexShader(source: Blob): VertexShader {
		return new Shader(source.toString(), Sys.gl.VERTEX_SHADER);
	}
	
	public function createFragmentShader(source: Blob): FragmentShader {
		return new Shader(source.toString(), Sys.gl.FRAGMENT_SHADER);
	}
	
	public function createProgram(): kha.graphics.Program {
		return new Program();
	}
	
	public function setProgram(program: kha.graphics.Program): Void {
		cast(program, Program).set();
	}
	
	public function setInt(location: kha.graphics.ConstantLocation, value: Int): Void {
		Sys.gl.uniform1i(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat(location: kha.graphics.ConstantLocation, value: Float): Void {
		Sys.gl.uniform1f(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat2(location: kha.graphics.ConstantLocation, value1: Float, value2: Float): Void {
		Sys.gl.uniform2f(cast(location, ConstantLocation).value, value1, value2);
	}
	
	public function setFloat3(location: kha.graphics.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		Sys.gl.uniform3f(cast(location, ConstantLocation).value, value1, value2, value3);
	}
	
	public function setMatrix(location: kha.graphics.ConstantLocation, matrix: Array<Float>): Void {
		Sys.gl.uniformMatrix4fv(cast(location, ConstantLocation).value, false, matrix);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		Sys.gl.drawElements(Sys.gl.TRIANGLES, count == -1 ? indicesCount : count, Sys.gl.UNSIGNED_SHORT, start * 2);
	}
	
	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		
	}

	public function setScissor(rect: Rectangle): Void {
		
	}
	
	public function renderToTexture(texture: Texture): Void {
		
	}

	public function renderToBackbuffer(): Void {
		
	}
}
