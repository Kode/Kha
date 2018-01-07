package kha.graphics4;

import js.html.webgl.GL;
import haxe.io.Bytes;
import kha.js.graphics4.Graphics;

class CubeMap implements Canvas implements Resource {

	private var myWidth: Int;
	private var myHeight: Int;
	private var format: TextureFormat;
	private var renderTarget: Bool;
	private var depthStencilFormat: DepthStencilFormat;
	private var graphics4: kha.graphics4.Graphics;

	public var frameBuffer: Dynamic = null;
	public var texture: Dynamic = null;
	public var depthTexture: Dynamic = null;
	public var isDepthAttachment: Bool = false;

	// WebGL2 constants
	private static inline var GL_RGBA16F = 0x881A;
	private static inline var GL_RGBA32F = 0x8814;
	private static inline var GL_R16F = 0x822D;
	private static inline var GL_R32F = 0x822E;
	private static inline var GL_DEPTH_COMPONENT24 = 0x81A6;
	private static inline var GL_DEPTH24_STENCIL8 = 0x88F0;
	private static inline var GL_DEPTH32F_STENCIL8 = 0x8CAD;

	private function new(size: Int, format: TextureFormat, renderTarget: Bool, depthStencilFormat: DepthStencilFormat) {
		myWidth = size;
		myHeight = size;
		this.format = format;
		this.renderTarget = renderTarget;
		this.depthStencilFormat = depthStencilFormat;
		if (renderTarget) createTexture();
	}

	public static function createRenderTarget(size: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = null, contextId: Int = 0): CubeMap {
		if (format == null) format = TextureFormat.RGBA32;
		if (depthStencil == null) depthStencil = NoDepthAndStencil;
		return new CubeMap(size, format, true, depthStencil);
	}

	private function createTexture() {
		if (SystemImpl.gl == null) return;

		texture = SystemImpl.gl.createTexture();
		SystemImpl.gl.bindTexture(GL.TEXTURE_CUBE_MAP, texture);

		SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);

		if (renderTarget) {

			frameBuffer = SystemImpl.gl.createFramebuffer();
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);

			switch (format) {
			case DEPTH16:
				for (i in 0...6) SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, SystemImpl.gl2 ? GL.DEPTH_COMPONENT16 : GL.DEPTH_COMPONENT, myWidth, myHeight, 0, GL.DEPTH_COMPONENT, GL.UNSIGNED_SHORT, null);
			case RGBA128:
				for (i in 0...6) SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, SystemImpl.gl2 ? GL_RGBA32F : GL.RGBA, myWidth, myHeight, 0, GL.RGBA, GL.FLOAT, null);
			case RGBA64:
				for (i in 0...6) SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, SystemImpl.gl2 ? GL_RGBA16F : GL.RGBA, myWidth, myHeight, 0, GL.RGBA, SystemImpl.halfFloat.HALF_FLOAT_OES, null);
			case RGBA32:
				for (i in 0...6) SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL.RGBA, myWidth, myHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
			case A32:
				for (i in 0...6) SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, SystemImpl.gl2 ? GL_R32F : GL.ALPHA, myWidth, myHeight, 0, GL.ALPHA, GL.FLOAT, null);
			case A16:
				for (i in 0...6) SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, SystemImpl.gl2 ? GL_R16F : GL.ALPHA, myWidth, myHeight, 0, GL.ALPHA, SystemImpl.halfFloat.HALF_FLOAT_OES, null);
			default:
				for (i in 0...6) SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL.RGBA, myWidth, myHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
			}

			if (format == DEPTH16) {
				SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
				isDepthAttachment = true;
				// Some WebGL implementations throw incomplete framebuffer error, create color attachment
				if (!SystemImpl.gl2) {
					var colortex = SystemImpl.gl.createTexture();
					SystemImpl.gl.bindTexture(GL.TEXTURE_CUBE_MAP, colortex);
					for (i in 0...6) {
						SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL.RGBA, myWidth, myHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
						SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_CUBE_MAP_POSITIVE_X + i, colortex, 0);
					}
					SystemImpl.gl.bindTexture(GL.TEXTURE_CUBE_MAP, texture);
				}
			}

			initDepthStencilBuffer(depthStencilFormat);
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, null);
		}

		SystemImpl.gl.bindTexture(GL.TEXTURE_CUBE_MAP, null);
	}

	private function initDepthStencilBuffer(depthStencilFormat: DepthStencilFormat) {
		switch (depthStencilFormat) {
		case NoDepthAndStencil: {}
		case DepthOnly, Depth16: {
			depthTexture = SystemImpl.gl.createTexture();
			SystemImpl.gl.bindTexture(GL.TEXTURE_CUBE_MAP, depthTexture);
			if (depthStencilFormat == DepthOnly) SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP, 0, SystemImpl.gl2 ? GL_DEPTH_COMPONENT24 : GL.DEPTH_COMPONENT, myWidth, myHeight, 0, GL.DEPTH_COMPONENT, GL.UNSIGNED_INT, null);
			else SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP, 0, SystemImpl.gl2 ? GL.DEPTH_COMPONENT16 : GL.DEPTH_COMPONENT, myWidth, myHeight, 0, GL.DEPTH_COMPONENT, GL.UNSIGNED_SHORT, null);
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
			SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.TEXTURE_CUBE_MAP, depthTexture, 0);
		}
		case DepthAutoStencilAuto, Depth24Stencil8, Depth32Stencil8:
			depthTexture = SystemImpl.gl.createTexture();
			SystemImpl.gl.bindTexture(GL.TEXTURE_CUBE_MAP, depthTexture);
			SystemImpl.gl.texImage2D(GL.TEXTURE_CUBE_MAP, 0, SystemImpl.gl2 ? GL_DEPTH24_STENCIL8 : GL.DEPTH_STENCIL, myWidth, myHeight, 0, GL.DEPTH_STENCIL, SystemImpl.depthTexture.UNSIGNED_INT_24_8_WEBGL, null);
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			SystemImpl.gl.texParameteri(GL.TEXTURE_CUBE_MAP, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
			SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.TEXTURE_CUBE_MAP, depthTexture, 0);
		}
	}

	public function set(stage: Int): Void {
		SystemImpl.gl.activeTexture(GL.TEXTURE0 + stage);
		SystemImpl.gl.bindTexture(GL.TEXTURE_CUBE_MAP, texture);
	}

	public function setDepth(stage: Int): Void {
		SystemImpl.gl.activeTexture(GL.TEXTURE0 + stage);
		SystemImpl.gl.bindTexture(GL.TEXTURE_CUBE_MAP, depthTexture);
	}

	public function unload(): Void { }
	public function lock(level: Int = 0): Bytes { return null; }
	public function unlock(): Void { }

	public var width(get, null): Int;
	private function get_width(): Int { return myWidth; }
	public var height(get, null): Int;
	private function get_height(): Int { return myHeight; }

	public var g1(get, null): kha.graphics1.Graphics;
	private function get_g1(): kha.graphics1.Graphics { return null; }
	public var g2(get, null): kha.graphics2.Graphics;
	private function get_g2(): kha.graphics2.Graphics { return null; }
	public var g4(get, null): kha.graphics4.Graphics;
	private function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new Graphics(this);
		}
		return graphics4;
	}
}
