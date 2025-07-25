package kha;

import haxe.io.Bytes;
import js.Browser;
import js.lib.Uint8Array;
import js.html.VideoElement;
import js.html.webgl.GL;
import kha.graphics4.TextureFormat;
import kha.js.CanvasGraphics;

class CanvasImage extends Image {
	public var image: Dynamic;
	public var video: VideoElement;

	static var context: Dynamic;

	var data: Dynamic;

	var myWidth: Int;
	var myHeight: Int;
	var myFormat: TextureFormat;
	var renderTarget: Bool;

	public var frameBuffer: Dynamic;

	var graphics1: kha.graphics1.Graphics;
	var g2canvas: CanvasGraphics = null;

	public static function init() {
		final canvas = Browser.document.createCanvasElement();
		if (canvas != null) {
			context = canvas.getContext("2d");
			canvas.width = 2048;
			canvas.height = 2048;
			context.globalCompositeOperation = "copy";
		}
	}

	public function new(width: Int, height: Int, format: TextureFormat, renderTarget: Bool) {
		myWidth = width;
		myHeight = height;
		myFormat = format;
		this.renderTarget = renderTarget;
		image = null;
		video = null;
		if (renderTarget)
			createTexture();
	}

	override function get_g1(): kha.graphics1.Graphics {
		if (graphics1 == null) {
			graphics1 = new kha.graphics2.Graphics1(this);
		}
		return graphics1;
	}

	override function get_g2(): kha.graphics2.Graphics {
		if (g2canvas == null) {
			final canvas = Browser.document.createCanvasElement();
			image = canvas;
			var context = canvas.getContext("2d");
			canvas.width = width;
			canvas.height = height;
			g2canvas = new CanvasGraphics(context);
		}
		return g2canvas;
	}

	override function get_g4(): kha.graphics4.Graphics {
		return null;
	}

	override function get_width(): Int {
		return myWidth;
	}

	override function get_height(): Int {
		return myHeight;
	}

	override function get_format(): TextureFormat {
		return myFormat;
	}

	override function get_realWidth(): Int {
		return myWidth;
	}

	override function get_realHeight(): Int {
		return myHeight;
	}

	override function get_stride(): Int {
		return myFormat == TextureFormat.RGBA32 ? 4 * width : width;
	}

	override public function isOpaque(x: Int, y: Int): Bool {
		if (data == null) {
			if (context == null)
				return true;
			else
				createImageData();
		}
		return (data.data[y * Std.int(image.width) * 4 + x * 4 + 3] != 0);
	}

	override public function at(x: Int, y: Int): Color {
		if (data == null) {
			if (context == null)
				return Color.Black;
			else
				createImageData();
		}

		var r = data.data[y * Std.int(image.width) * 4 + x * 4];
		var g = data.data[y * Std.int(image.width) * 4 + x * 4 + 1];
		var b = data.data[y * Std.int(image.width) * 4 + x * 4 + 2];
		var a = data.data[y * Std.int(image.width) * 4 + x * 4 + 3];

		return Color.fromValue((a << 24) | (r << 16) | (g << 8) | b);
	}

	function createImageData() {
		context.strokeStyle = "rgba(0,0,0,0)";
		context.fillStyle = "rgba(0,0,0,0)";
		context.fillRect(0, 0, image.width, image.height);
		context.drawImage(image, 0, 0, image.width, image.height, 0, 0, image.width, image.height);
		data = context.getImageData(0, 0, image.width, image.height);
	}

	var texture: Dynamic;

	static function upperPowerOfTwo(v: Int): Int {
		v--;
		v |= v >>> 1;
		v |= v >>> 2;
		v |= v >>> 4;
		v |= v >>> 8;
		v |= v >>> 16;
		v++;
		return v;
	}

	public function createTexture() {
		if (SystemImpl.gl == null)
			return;
		texture = SystemImpl.gl.createTexture();
		// texture.image = image;
		SystemImpl.gl.bindTexture(GL.TEXTURE_2D, texture);
		// Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);

		SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		if (renderTarget) {
			frameBuffer = SystemImpl.gl.createFramebuffer();
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
			SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, realWidth, realHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
			SystemImpl.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
			SystemImpl.gl.bindFramebuffer(GL.FRAMEBUFFER, null);
		}
		else if (video != null)
			SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, video);
		else
			SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, image);
		// Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
		SystemImpl.gl.bindTexture(GL.TEXTURE_2D, null);
	}

	public function set(stage: Int): Void {
		SystemImpl.gl.activeTexture(GL.TEXTURE0 + stage);
		SystemImpl.gl.bindTexture(GL.TEXTURE_2D, texture);
		if (video != null)
			SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, video);
	}

	public var bytes: Bytes;

	override public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(myFormat == TextureFormat.RGBA32 ? 4 * width * height : width * height);
		return bytes;
	}

	override public function unlock(): Void {
		data = null;

		if (SystemImpl.gl != null) {
			texture = SystemImpl.gl.createTexture();
			// texture.image = image;
			SystemImpl.gl.bindTexture(GL.TEXTURE_2D, texture);
			// Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);

			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			SystemImpl.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.LUMINANCE, width, height, 0, GL.LUMINANCE, GL.UNSIGNED_BYTE, new Uint8Array(bytes.getData()));

			if (SystemImpl.ie && SystemImpl.gl.getError() == 1282) { // no LUMINANCE support in IE11
				var rgbaBytes = Bytes.alloc(width * height * 4);
				for (y in 0...height)
					for (x in 0...width) {
						var value = bytes.get(y * width + x);
						rgbaBytes.set(y * width * 4 + x * 4 + 0, value);
						rgbaBytes.set(y * width * 4 + x * 4 + 1, value);
						rgbaBytes.set(y * width * 4 + x * 4 + 2, value);
						rgbaBytes.set(y * width * 4 + x * 4 + 3, 255);
					}
				SystemImpl.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, new Uint8Array(rgbaBytes.getData()));
			}

			// Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
			SystemImpl.gl.bindTexture(GL.TEXTURE_2D, null);
			bytes = null;
		}
	}

	override public function getPixels(): Bytes {
		@:privateAccess var context: js.html.CanvasRenderingContext2D = g2canvas.canvas;
		var imageData: js.html.ImageData = context.getImageData(0, 0, width, height);
		var bytes = Bytes.alloc(imageData.data.length);
		for (i in 0...imageData.data.length) {
			bytes.set(i, imageData.data[i]);
		}
		return bytes;
	}

	override public function unload(): Void {
		image = null;
		video = null;
		data = null;
	}
}
