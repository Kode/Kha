package kha;

import haxe.io.Bytes;
import js.Browser;
import js.lib.Uint8Array;
import js.lib.Uint16Array;
import js.lib.Float32Array;
import js.html.VideoElement;
import js.html.webgl.GL;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.js.graphics4.Graphics;

class WebGLImage extends Image {
	public var image: Dynamic;
	public var video: VideoElement;

	private static var context: Dynamic;
	private var data: Dynamic;

	private var myWidth: Int;
	private var myHeight: Int;
	private var format: TextureFormat;
	private var renderTarget: Bool;
	private var samples: Int;
	public var frameBuffer: Dynamic = null;
	public var renderBuffer: Dynamic = null;
	public var texture: Dynamic = null;
	public var depthTexture: Dynamic = null;
	public var MSAAFrameBuffer:Dynamic=null;
	var MSAAColorBuffer:Dynamic;
	var MSAADepthBuffer:Dynamic;


	private var graphics1: kha.graphics1.Graphics;
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;

	private var depthStencilFormat: DepthStencilFormat;

	// WebGL2 constants
	private static inline var GL_RGBA16F = 0x881A;
	private static inline var GL_RGBA32F = 0x8814;
	private static inline var GL_R16F = 0x822D;
	private static inline var GL_R32F = 0x822E;
	private static inline var GL_RED = 0x1903;
	private static inline var GL_DEPTH_COMPONENT24 = 0x81A6;
	private static inline var GL_DEPTH24_STENCIL8 = 0x88F0;
	private static inline var GL_DEPTH32F_STENCIL8 = 0x8CAD;

	static var canvas: js.html.CanvasElement;

	public static function init() {
		if (context == null) {
			// create only once
			canvas = cast Browser.document.createElement("canvas");
			if (canvas != null) {
				context = canvas.getContext("2d");
				canvas.width = 4096;
				canvas.height = 4096;
				context.globalCompositeOperation = "copy";
			}
		}
	}

	public function new(width: Int, height: Int, format: TextureFormat, renderTarget: Bool, depthStencilFormat: DepthStencilFormat, samples: Int) {
		myWidth = width;
		myHeight = height;
		this.format = format;
		this.renderTarget = renderTarget;
		this.samples = samples;
		image = null;
		video = null;
		this.depthStencilFormat = depthStencilFormat;
		init();
		if (renderTarget) createTexture();
	}

	override private function get_g1(): kha.graphics1.Graphics {
		if (graphics1 == null) {
			graphics1 = new kha.graphics2.Graphics1(this);
		}
		return graphics1;
	}

	override private function get_g2(): kha.graphics2.Graphics {
		if (graphics2 == null) {
			graphics2 = new kha.js.graphics4.Graphics2(this);
		}
		return graphics2;
	}

	override private function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new Graphics(this);
		}
		return graphics4;
	}

	override private function get_width(): Int {
		return myWidth;
	}

	override private function get_height(): Int {
		return myHeight;
	}

	override private function get_realWidth(): Int {
		return myWidth;
	}

	override private function get_realHeight(): Int {
		return myHeight;
	}

	override public function isOpaque(x: Int, y: Int): Bool {
		if (data == null) {
			if (context == null) return true;
			else createImageData();
		}
		return (data.data[y * Std.int(image.width) * 4 + x * 4 + 3] != 0);
	}

	override public function at(x: Int, y: Int): Color {
		if (data == null) {
			if (context == null) return Color.Black;
			else createImageData();
		}
		
		var r = data.data[y * width * 4 + x * 4];
		var g = data.data[y * width * 4 + x * 4 + 1];
		var b = data.data[y * width * 4 + x * 4 + 2];
		var a = data.data[y * width * 4 + x * 4 + 3];
		
		return Color.fromValue((a << 24) | (r << 16) | (g << 8) | b);
	}

	function createImageData() {
		if (Std.is(image, Uint8Array)) {
			data = new js.html.ImageData(new js.lib.Uint8ClampedArray(image.buffer), this.width, this.height);
		} 
		else {
			if (this.width > canvas.width || this.height > canvas.height) {
				var cw = canvas.width;
				var ch = canvas.height;
				while (this.width > cw || this.height > ch) {
					cw *= 2;
					ch *= 2;
				}
				canvas.width = cw;
				canvas.height = ch;
			}
			context.strokeStyle = "rgba(0,0,0,0)";
			context.fillStyle = "rgba(0,0,0,0)";
			context.fillRect(0, 0, image.width, image.height);
			context.drawImage(image, 0, 0, image.width, image.height, 0, 0, image.width, image.height);
			data = context.getImageData(0, 0, image.width, image.height);
		}
	}

	private static function upperPowerOfTwo(v: Int): Int {
		v--;
		v |= v >>> 1;
		v |= v >>> 2;
		v |= v >>> 4;
		v |= v >>> 8;
		v |= v >>> 16;
		v++;
		return v;
	}

	public function createTexture(): Void {
		if (SystemImpl.gl == null) return;
		texture = SystemImpl.gl.createTexture();
		//texture.image = image;
		SystemImpl.gl.bindTexture(GL.TEXTURE_2D, texture);
		//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);

		SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		if (renderTarget) {
			frameBuffer = SystemImpl.gl.createFramebuffer();
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
			switch (format) {
			case DEPTH16:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL.DEPTH_COMPONENT16 : GL.DEPTH_COMPONENT, realWidth, realHeight, 0, GL.DEPTH_COMPONENT, GL.UNSIGNED_SHORT, null);
			case RGBA128:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_RGBA32F : GL.RGBA, realWidth, realHeight, 0, GL.RGBA, GL.FLOAT, null);
			case RGBA64:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_RGBA16F : GL.RGBA, realWidth, realHeight, 0, GL.RGBA, SystemImpl.halfFloat.HALF_FLOAT_OES, null);
			case RGBA32:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, realWidth, realHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
			case A32:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_R32F : GL.ALPHA, realWidth, realHeight, 0, SystemImpl.gl2 ? GL_RED : GL.ALPHA, GL.FLOAT, null);
			case A16:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_R16F : GL.ALPHA, realWidth, realHeight, 0, SystemImpl.gl2 ? GL_RED : GL.ALPHA, SystemImpl.halfFloat.HALF_FLOAT_OES, null);
			default:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, realWidth, realHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
			}

			if (format == DEPTH16) {
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
				SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.TEXTURE_2D, texture, 0);
				// Some WebGL implementations throw incomplete framebuffer error, create color attachment
				if (!SystemImpl.gl2) {
					var colortex = SystemImpl.gl.createTexture();
					SystemImpl.gl.bindTexture(GL.TEXTURE_2D, colortex);
					SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, realWidth, realHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
					SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, colortex, 0);
					SystemImpl.gl.bindTexture(GL.TEXTURE_2D, texture);
				}
			}
			else {
				if (samples>1&&SystemImpl.gl2) {
					MSAAFrameBuffer = SystemImpl.gl.createFramebuffer();
					MSAAColorBuffer = SystemImpl.gl.createRenderbuffer();
					SystemImpl.gl.bindRenderbuffer(GL.RENDERBUFFER, MSAAColorBuffer);
					var MSAAFormat=switch (format) {
					case RGBA128:
						untyped SystemImpl.gl.RGBA32F;
					case RGBA64:
						untyped SystemImpl.gl.RGBA16F;
					case RGBA32:
						untyped SystemImpl.gl.RGBA8;
					case A32:
						GL_R32F;
					case A16:
						GL_R16F;
					default:
						untyped SystemImpl.gl.RGBA8;
					};
					untyped SystemImpl.gl.renderbufferStorageMultisample(GL.RENDERBUFFER,samples, MSAAFormat, realWidth, realHeight);
					SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
					SystemImpl.gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.RENDERBUFFER, MSAAColorBuffer);
					SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, MSAAFrameBuffer);
				}
				SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER,GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
				SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, null);
			}
			
			initDepthStencilBuffer(depthStencilFormat);
			var e=SystemImpl.gl.checkFramebufferStatus(GL.FRAMEBUFFER);
			if (e != GL.FRAMEBUFFER_COMPLETE) {
				trace("checkframebufferStatus error "+e);
			}

			SystemImpl.gl.bindRenderbuffer(GL.RENDERBUFFER, null);
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, null);
		}
		else if (video != null) {
			SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, video);
		}
		else {
			switch (format) {
			case RGBA128:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_RGBA32F : GL.RGBA, myWidth, myHeight, 0, GL.RGBA, GL.FLOAT, image);
			case RGBA64:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_RGBA16F : GL.RGBA, myWidth, myHeight, 0, GL.RGBA, SystemImpl.halfFloat.HALF_FLOAT_OES, image);
			case RGBA32:
				if (Std.is(image, Uint8Array)) {
					SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, myWidth, myHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, image);
				}
				else {
					SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, image);
				}
			case A32:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_R32F : GL.ALPHA, myWidth, myHeight, 0, SystemImpl.gl2 ? GL_RED : GL.ALPHA, GL.FLOAT, image);
			case A16:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_R16F : GL.ALPHA, myWidth, myHeight, 0, SystemImpl.gl2 ? GL_RED : GL.ALPHA, SystemImpl.halfFloat.HALF_FLOAT_OES, image);
			case L8:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.LUMINANCE, myWidth, myHeight, 0, GL.LUMINANCE, GL.UNSIGNED_BYTE, image);
			default:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, image);
			}
		}
		SystemImpl.gl.bindTexture(GL.TEXTURE_2D, null);
	}

	private function initDepthStencilBuffer(depthStencilFormat: DepthStencilFormat) {
		switch (depthStencilFormat) {
		case NoDepthAndStencil:
		case DepthOnly, Depth16: {
			if (SystemImpl.depthTexture == null) {
				renderBuffer = SystemImpl.gl.createRenderbuffer();
				SystemImpl.gl.bindRenderbuffer(GL.RENDERBUFFER, renderBuffer);
				SystemImpl.gl.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, realWidth, realHeight); 
				SystemImpl.gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderBuffer);
			}
			else {
				depthTexture = SystemImpl.gl.createTexture();
				SystemImpl.gl.bindTexture(GL.TEXTURE_2D, depthTexture);
				if (depthStencilFormat == DepthOnly) SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_DEPTH_COMPONENT24 : GL.DEPTH_COMPONENT, realWidth, realHeight, 0, GL.DEPTH_COMPONENT, GL.UNSIGNED_INT, null);
				else SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL.DEPTH_COMPONENT16 : GL.DEPTH_COMPONENT, realWidth, realHeight, 0, GL.DEPTH_COMPONENT, GL.UNSIGNED_SHORT, null);
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
				SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
				
				if (samples>1&&SystemImpl.gl2) {
					MSAADepthBuffer = SystemImpl.gl.createRenderbuffer();
					SystemImpl.gl.bindRenderbuffer(GL.RENDERBUFFER, MSAADepthBuffer);
					if (depthStencilFormat == DepthOnly) untyped SystemImpl.gl.renderbufferStorageMultisample(GL.RENDERBUFFER,samples,GL_DEPTH_COMPONENT24, realWidth, realHeight);
					else untyped SystemImpl.gl.renderbufferStorageMultisample(GL.RENDERBUFFER,samples,GL.DEPTH_COMPONENT16, realWidth, realHeight);
					SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
					SystemImpl.gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, MSAADepthBuffer);
					SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, MSAAFrameBuffer);
					
				}
				SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.TEXTURE_2D, depthTexture, 0);
				SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, null);
				
			}
		}
		case DepthAutoStencilAuto, Depth24Stencil8, Depth32Stencil8:
			if (SystemImpl.depthTexture == null) {
				renderBuffer = SystemImpl.gl.createRenderbuffer();
				SystemImpl.gl.bindRenderbuffer(GL.RENDERBUFFER, renderBuffer);
				SystemImpl.gl.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_STENCIL, realWidth, realHeight);
				SystemImpl.gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.RENDERBUFFER, renderBuffer);
			}
			else {
				depthTexture = SystemImpl.gl.createTexture();
				SystemImpl.gl.bindTexture(GL.TEXTURE_2D, depthTexture);
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_DEPTH24_STENCIL8 : GL.DEPTH_STENCIL, realWidth, realHeight, 0, GL.DEPTH_STENCIL, SystemImpl.depthTexture.UNSIGNED_INT_24_8_WEBGL, null);
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
				SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
				SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
				if (samples>1&&SystemImpl.gl2) {
					MSAADepthBuffer = SystemImpl.gl.createRenderbuffer();
					SystemImpl.gl.bindRenderbuffer(GL.RENDERBUFFER, MSAADepthBuffer);
					untyped SystemImpl.gl.renderbufferStorageMultisample(GL.RENDERBUFFER,samples, GL_DEPTH24_STENCIL8, realWidth, realHeight);
					SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
					SystemImpl.gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.RENDERBUFFER, MSAADepthBuffer);
					SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, MSAAFrameBuffer);
					
				}
				SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.TEXTURE_2D, depthTexture, 0);
			}
		}
	}

	public function set(stage: Int): Void {
		SystemImpl.gl.activeTexture(GL.TEXTURE0 + stage);
		SystemImpl.gl.bindTexture(GL.TEXTURE_2D, texture);
		if (video != null) SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, video);
	}

	public function setDepth(stage: Int): Void {
		SystemImpl.gl.activeTexture(GL.TEXTURE0 + stage);
		SystemImpl.gl.bindTexture(GL.TEXTURE_2D, depthTexture);
	}

	override public function setDepthStencilFrom(image: Image): Void {
		depthTexture = cast(image, WebGLImage).depthTexture;
		SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
		SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.TEXTURE_2D, depthTexture, 0);
	}

	private static function formatByteSize(format: TextureFormat): Int {
		return switch(format) {
			case RGBA32: 4;
			case L8: 1;
			case RGBA128: 16;
			case DEPTH16: 2;
			case RGBA64: 8;
			case A32: 4;
			case A16: 2;
			default: 4;
		}
	}

	public function bytesToArray(bytes: Bytes): Dynamic {
		return switch(format) {
			case RGBA32, L8:
				new Uint8Array(bytes.getData());
			case RGBA128, RGBA64, A32, A16:
				new Float32Array(bytes.getData());
			default:
				new Uint8Array(bytes.getData());
		}
	}

	public var bytes: Bytes;

	override public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(formatByteSize(format) * width * height);
		return bytes;
	}

	override public function unlock(): Void {
		if (SystemImpl.gl != null) {
			texture = SystemImpl.gl.createTexture();
			//texture.image = image;
			SystemImpl.gl.bindTexture(GL.TEXTURE_2D, texture);
			//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);

			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);

			switch (format) {
			case L8:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.LUMINANCE, width, height, 0, GL.LUMINANCE, GL.UNSIGNED_BYTE, bytesToArray(bytes));

				if (SystemImpl.gl.getError() == 1282) { // no LUMINANCE support in IE11
					var rgbaBytes = Bytes.alloc(width * height * 4);
					for (y in 0...height) for (x in 0...width) {
						var value = bytes.get(y * width + x);
						rgbaBytes.set(y * width * 4 + x * 4 + 0, value);
						rgbaBytes.set(y * width * 4 + x * 4 + 1, value);
						rgbaBytes.set(y * width * 4 + x * 4 + 2, value);
						rgbaBytes.set(y * width * 4 + x * 4 + 3, 255);
					}
					SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, bytesToArray(rgbaBytes));
				}
			case RGBA128:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_RGBA32F : GL.RGBA, width, height, 0, GL.RGBA, GL.FLOAT, bytesToArray(bytes));
			case RGBA64:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_RGBA16F : GL.RGBA, width, height, 0, GL.RGBA, SystemImpl.halfFloat.HALF_FLOAT_OES, bytesToArray(bytes));
			case A32:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_R32F : GL.ALPHA, width, height, 0, SystemImpl.gl2 ? GL_RED : GL.ALPHA, GL.FLOAT, bytesToArray(bytes));
			case A16:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, SystemImpl.gl2 ? GL_R16F : GL.ALPHA, width, height, 0, SystemImpl.gl2 ? GL_RED : GL.ALPHA, SystemImpl.halfFloat.HALF_FLOAT_OES, bytesToArray(bytes));
			case RGBA32:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, bytesToArray(bytes));
			default:
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, bytesToArray(bytes));
			}

			SystemImpl.gl.bindTexture(GL.TEXTURE_2D, null);
			bytes = null;
		}
	}

	private var pixels: js.lib.ArrayBufferView = null;
	
	override public function getPixels(): Bytes {
		if (frameBuffer == null) return null;
		if (pixels == null) {
			switch (format) {
			case RGBA128, A32:
				pixels = new Float32Array(Std.int(formatByteSize(format) / 4) * width * height);
			case RGBA64, A16:
				pixels = new Uint16Array(Std.int(formatByteSize(format) / 2) * width * height);
			case RGBA32, L8:
				pixels = new Uint8Array(formatByteSize(format) * width * height);
			default:
				pixels = new Uint8Array(formatByteSize(format) * width * height);
			}
		}
		SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
		switch (format) {
		case RGBA128:
			SystemImpl.gl.readPixels(0, 0, myWidth, myHeight, GL.RGBA, GL.FLOAT, pixels);
		case RGBA64:
			SystemImpl.gl.readPixels(0, 0, myWidth, myHeight, GL.RGBA, SystemImpl.halfFloat.HALF_FLOAT_OES, pixels);
		case RGBA32:
			SystemImpl.gl.readPixels(0, 0, myWidth, myHeight, GL.RGBA, GL.UNSIGNED_BYTE, pixels);
		case A32:
			SystemImpl.gl.readPixels(0, 0, myWidth, myHeight, SystemImpl.gl2 ? GL_RED : GL.ALPHA, GL.FLOAT, pixels);
		case A16:
			SystemImpl.gl.readPixels(0, 0, myWidth, myHeight, SystemImpl.gl2 ? GL_RED : GL.ALPHA, SystemImpl.halfFloat.HALF_FLOAT_OES, pixels);
		case L8:
			SystemImpl.gl.readPixels(0, 0, myWidth, myHeight, SystemImpl.gl2 ? GL_RED : GL.ALPHA, GL.UNSIGNED_BYTE, pixels);
		default:
			SystemImpl.gl.readPixels(0, 0, myWidth, myHeight, GL.RGBA, GL.UNSIGNED_BYTE, pixels);
		}
		return Bytes.ofData(pixels.buffer);
	}

	override public function unload(): Void {
		if (texture != null) SystemImpl.gl.deleteTexture(texture);
		if (depthTexture != null) SystemImpl.gl.deleteTexture(depthTexture);
		if (frameBuffer != null) SystemImpl.gl.deleteFramebuffer(frameBuffer);
		if (renderBuffer != null) SystemImpl.gl.deleteRenderbuffer(renderBuffer);
		if (MSAAFrameBuffer != null) SystemImpl.gl.deleteFramebuffer(MSAAFrameBuffer);
		if(MSAAColorBuffer != null)SystemImpl.gl.deleteRenderbuffer(MSAAColorBuffer);
		if(MSAADepthBuffer != null)SystemImpl.gl.deleteRenderbuffer(MSAADepthBuffer);
	}

	override public function generateMipmaps(levels: Int): Void {
		// WebGL requires to generate all mipmaps down to 1x1 size, ignoring levels for now
		SystemImpl.gl.bindTexture(GL.TEXTURE_2D, texture);
		SystemImpl.gl.generateMipmap(GL.TEXTURE_2D);
	}

	override public function setMipmaps(mipmaps: Array<Image>): Void {
		// Similar to generateMipmaps, specify all the levels down to 1x1 size
		SystemImpl.gl.bindTexture(GL.TEXTURE_2D, texture);
		if (format == TextureFormat.RGBA128) {
			for (i in 0...mipmaps.length) {
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, i + 1, SystemImpl.gl2 ? GL_RGBA32F : GL.RGBA, mipmaps[i].width, mipmaps[i].height, 0, GL.RGBA, GL.FLOAT, cast(mipmaps[i], WebGLImage).image);
			}
		}
		else if (format == TextureFormat.RGBA64) {
			for (i in 0...mipmaps.length) {
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, i + 1, SystemImpl.gl2 ? GL_RGBA16F : GL.RGBA, mipmaps[i].width, mipmaps[i].height, 0, GL.RGBA, SystemImpl.halfFloat.HALF_FLOAT_OES, cast(mipmaps[i], WebGLImage).image);
			}
		}
		else {
			for (i in 0...mipmaps.length) {
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, i + 1, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, cast(mipmaps[i], WebGLImage).image);
			}
		}
	}
}
