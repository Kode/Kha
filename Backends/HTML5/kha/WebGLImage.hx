package kha;

import haxe.io.Bytes;
import js.Browser;
import js.html.ImageElement;
import js.html.Uint8Array;
import js.html.VideoElement;
import kha.graphics4.TextureFormat;
import kha.js.CanvasGraphics;

class WebGLImage {
	public var image: Dynamic;
	private var video: VideoElement;
	
	private static var context: Dynamic;
	private var data: Dynamic;
	
	private var myWidth: Int;
	private var myHeight: Int;
	private var format: TextureFormat;
	private var renderTarget: Bool;
	public var frameBuffer: Dynamic;
	
	private var g2canvas: CanvasGraphics = null;
	
	public static function init() {
		var canvas: Dynamic = Browser.document.createElement("canvas");
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
		this.format = format;
		this.renderTarget = renderTarget;
		image = null;
		video = null;
		if (renderTarget) createTexture();
	}
		
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		if (g2canvas == null) {
			var canvas: Dynamic = Browser.document.createElement("canvas");
			image = canvas;
			var context = canvas.getContext("2d");
			canvas.width = width;
			canvas.height = height;
			g2canvas = new CanvasGraphics(context, width, height);
		}
		return g2canvas;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	
	private function get_g4(): kha.graphics4.Graphics {
		return null;
	}
	
	public var width(get, null): Int;
	
	private function get_width(): Int {
		return myWidth;
	}
	
	public var height(get, null): Int;
	
	private function get_height(): Int {
		return myHeight;
	}
	
	public var realWidth(get, null): Int;
	
	private function get_realWidth(): Int {
		return myWidth;
	}
	
	public var realHeight(get, null): Int;
	
	private function get_realHeight(): Int {
		return myHeight;
	}
	
	public function isOpaque(x: Int, y: Int): Bool {
		if (data == null) {
			if (context == null) return true;
			else createImageData();
		}
		return (data.data[y * Std.int(image.width) * 4 + x * 4 + 3] != 0);
	}
	
	function createImageData() {
		context.strokeStyle = "rgba(0,0,0,0)";
		context.fillStyle = "rgba(0,0,0,0)";
		context.fillRect(0, 0, image.width, image.height);
		context.drawImage(image, 0, 0, image.width, image.height, 0, 0, image.width, image.height);
		data = context.getImageData(0, 0, image.width, image.height);
	}
		
	private var texture: Dynamic;
	
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
	
	public function createTexture() {
		if (Sys.gl == null) return;
		texture = Sys.gl.createTexture();
		//texture.image = image;
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, texture);
		//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);
		
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.LINEAR);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.CLAMP_TO_EDGE);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.CLAMP_TO_EDGE);
		if (renderTarget) {
			frameBuffer = Sys.gl.createFramebuffer();
			Sys.gl.bindFramebuffer(Sys.gl.FRAMEBUFFER, frameBuffer);
			Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.RGBA, realWidth, realHeight, 0, Sys.gl.RGBA, Sys.gl.UNSIGNED_BYTE, null);
			Sys.gl.framebufferTexture2D(Sys.gl.FRAMEBUFFER, Sys.gl.COLOR_ATTACHMENT0, Sys.gl.TEXTURE_2D, texture, 0);
			Sys.gl.bindFramebuffer(Sys.gl.FRAMEBUFFER, null);
		}
		else if (video != null) Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.RGBA, Sys.gl.RGBA, Sys.gl.UNSIGNED_BYTE, video);
		else Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.RGBA, Sys.gl.RGBA, Sys.gl.UNSIGNED_BYTE, image);
		//Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, null);
	}
	
	public function set(stage: Int): Void {
		Sys.gl.activeTexture(Sys.gl.TEXTURE0 + stage);
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, texture);
		if (video != null) Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.RGBA, Sys.gl.RGBA, Sys.gl.UNSIGNED_BYTE, video);
	}
	
	public var bytes: Bytes;
	
	public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(format == TextureFormat.RGBA32 ? 4 * width * height : width * height);
		return bytes;
	}
	
	public function unlock(): Void {
		if (Sys.gl != null) {
			texture = Sys.gl.createTexture();
			//texture.image = image;
			Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, texture);
			//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);
			
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.LINEAR);
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR);
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.CLAMP_TO_EDGE);
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.CLAMP_TO_EDGE);
			Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.LUMINANCE, width, height, 0, Sys.gl.LUMINANCE, Sys.gl.UNSIGNED_BYTE, new Uint8Array(bytes.getData()));
			
			if (Sys.gl.getError() == 1282) {
				var rgbaBytes = Bytes.alloc(width * height * 4);
				for (y in 0...height) for (x in 0...width) {
					var value = bytes.get(y * width + x);
					rgbaBytes.set(y * width * 4 + x * 4 + 0, value);
					rgbaBytes.set(y * width * 4 + x * 4 + 1, value);
					rgbaBytes.set(y * width * 4 + x * 4 + 2, value);
					rgbaBytes.set(y * width * 4 + x * 4 + 3, 255);
				}
				Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.RGBA, width, height, 0, Sys.gl.RGBA, Sys.gl.UNSIGNED_BYTE, new Uint8Array(rgbaBytes.getData()));
			}
			
			//Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
			Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, null);
			bytes = null;
		}
	}
	
	public function unload(): Void {
		
	}
}
