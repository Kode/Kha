package kha;

import haxe.io.Bytes;
import js.Browser;
import js.html.ImageElement;
import js.html.Uint8Array;
import js.html.VideoElement;
import kha.graphics4.TextureFormat;
import kha.js.CanvasGraphics;

class CanvasImage extends Image {
	public var image: Dynamic;
	public var video: VideoElement;
	
	private static var context: Dynamic;
	private var data: Dynamic;
	
	private var myWidth: Int;
	private var myHeight: Int;
	private var format: TextureFormat;
	private var renderTarget: Bool;
	public var frameBuffer: Dynamic;
	
	private var graphics1: kha.graphics1.Graphics;
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
	
	override private function get_g1(): kha.graphics1.Graphics {
		if (graphics1 == null) {
			graphics1 = new kha.graphics2.Graphics1(this);
		}
		return graphics1;
	}
	
	override private function get_g2(): kha.graphics2.Graphics {
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
	
	override private function get_g4(): kha.graphics4.Graphics {
		return null;
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
		return Color.fromValue(data.data[y * Std.int(image.width) * 4 + x * 4 + 0]);
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
		if (SystemImpl.gl == null) return;
		texture = SystemImpl.gl.createTexture();
		//texture.image = image;
		SystemImpl.gl.bindTexture(SystemImpl.gl.TEXTURE_2D, texture);
		//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);
		
		SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MAG_FILTER, SystemImpl.gl.LINEAR);
		SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MIN_FILTER, SystemImpl.gl.LINEAR);
		SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_S, SystemImpl.gl.CLAMP_TO_EDGE);
		SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_T, SystemImpl.gl.CLAMP_TO_EDGE);
		if (renderTarget) {
			frameBuffer = SystemImpl.gl.createFramebuffer();
			SystemImpl.gl.bindFramebuffer(SystemImpl.gl.FRAMEBUFFER, frameBuffer);
			SystemImpl.gl.texImage2D(SystemImpl.gl.TEXTURE_2D, 0, SystemImpl.gl.RGBA, realWidth, realHeight, 0, SystemImpl.gl.RGBA, SystemImpl.gl.UNSIGNED_BYTE, null);
			SystemImpl.gl.framebufferTexture2D(SystemImpl.gl.FRAMEBUFFER, SystemImpl.gl.COLOR_ATTACHMENT0, SystemImpl.gl.TEXTURE_2D, texture, 0);
			SystemImpl.gl.bindFramebuffer(SystemImpl.gl.FRAMEBUFFER, null);
		}
		else if (video != null) SystemImpl.gl.texImage2D(SystemImpl.gl.TEXTURE_2D, 0, SystemImpl.gl.RGBA, SystemImpl.gl.RGBA, SystemImpl.gl.UNSIGNED_BYTE, video);
		else SystemImpl.gl.texImage2D(SystemImpl.gl.TEXTURE_2D, 0, SystemImpl.gl.RGBA, SystemImpl.gl.RGBA, SystemImpl.gl.UNSIGNED_BYTE, image);
		//Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
		SystemImpl.gl.bindTexture(SystemImpl.gl.TEXTURE_2D, null);
	}
	
	public function set(stage: Int): Void {
		SystemImpl.gl.activeTexture(SystemImpl.gl.TEXTURE0 + stage);
		SystemImpl.gl.bindTexture(SystemImpl.gl.TEXTURE_2D, texture);
		if (video != null) SystemImpl.gl.texImage2D(SystemImpl.gl.TEXTURE_2D, 0, SystemImpl.gl.RGBA, SystemImpl.gl.RGBA, SystemImpl.gl.UNSIGNED_BYTE, video);
	}
	
	public var bytes: Bytes;
	
	override public function lock(level: Int = 0): Bytes {
		bytes = Bytes.alloc(format == TextureFormat.RGBA32 ? 4 * width * height : width * height);
		return bytes;
	}
	
	override public function unlock(): Void {
		if (SystemImpl.gl != null) {
			texture = SystemImpl.gl.createTexture();
			//texture.image = image;
			SystemImpl.gl.bindTexture(SystemImpl.gl.TEXTURE_2D, texture);
			//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);
			
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MAG_FILTER, SystemImpl.gl.LINEAR);
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_MIN_FILTER, SystemImpl.gl.LINEAR);
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_S, SystemImpl.gl.CLAMP_TO_EDGE);
			SystemImpl.gl.texParameteri(SystemImpl.gl.TEXTURE_2D, SystemImpl.gl.TEXTURE_WRAP_T, SystemImpl.gl.CLAMP_TO_EDGE);
			SystemImpl.gl.texImage2D(SystemImpl.gl.TEXTURE_2D, 0, SystemImpl.gl.LUMINANCE, width, height, 0, SystemImpl.gl.LUMINANCE, SystemImpl.gl.UNSIGNED_BYTE, new Uint8Array(bytes.getData()));
			
			if (SystemImpl.gl.getError() == 1282) {
				var rgbaBytes = Bytes.alloc(width * height * 4);
				for (y in 0...height) for (x in 0...width) {
					var value = bytes.get(y * width + x);
					rgbaBytes.set(y * width * 4 + x * 4 + 0, value);
					rgbaBytes.set(y * width * 4 + x * 4 + 1, value);
					rgbaBytes.set(y * width * 4 + x * 4 + 2, value);
					rgbaBytes.set(y * width * 4 + x * 4 + 3, 255);
				}
				SystemImpl.gl.texImage2D(SystemImpl.gl.TEXTURE_2D, 0, SystemImpl.gl.RGBA, width, height, 0, SystemImpl.gl.RGBA, SystemImpl.gl.UNSIGNED_BYTE, new Uint8Array(rgbaBytes.getData()));
			}
			
			//Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
			SystemImpl.gl.bindTexture(SystemImpl.gl.TEXTURE_2D, null);
			bytes = null;
		}
	}
	
	override public function unload(): Void {
		
	}
}
