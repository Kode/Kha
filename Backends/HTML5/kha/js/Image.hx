package kha.js;

import js.Browser;
import js.html.ImageElement;
import kha.graphics.Texture;

class Image implements Texture {
	public var image: ImageElement;
	
	private static var context : Dynamic;
	private var data : Dynamic;
	
	public static function init() {
		var canvas : Dynamic = Browser.document.createElement("canvas");
		if (canvas != null) {
			context = canvas.getContext("2d");
			canvas.width = 2048;
			canvas.height = 2048;
		}
	}
	
	public function new(image: ImageElement) {
		this.image = image;
		createTexture();
	}
	
	public var width(get, null): Int;
	public var height(get, null): Int;
	
	public function get_width() : Int {
		return image.width;
	}
	
	public function get_height() : Int {
		return image.height;
	}
	
	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;
	
	public function get_realWidth(): Int {
		return image.width;
	}
	
	public function get_realHeight(): Int {
		return image.height;
	}
	
	public function isOpaque(x : Int, y : Int) : Bool {
		if (data == null) {
			if (context == null) return true;
			else createImageData();
		}
		var r = data.data[y * image.width * 4 + x * 4 + 0];
		var g = data.data[y * image.width * 4 + x * 4 + 1];
		return !(data.data[y * image.width * 4 + x * 4 + 0] == 255 && data.data[y * image.width * 4 + x * 4 + 1] == 255);
	}
	
	function createImageData() {
		context.strokeStyle = "rgb(255,255,0)";
		context.fillStyle = "rgb(255,255,0)";
		context.fillRect(0, 0, image.width, image.height);
		context.drawImage(image, 0, 0, image.width, image.height, 0, 0, image.width, image.height);
		data = context.getImageData(0, 0, image.width, image.height);
	}
	
	public function unload(): Void {
		
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
		texture.image = image;
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, texture);
		//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);
		
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.LINEAR);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.CLAMP_TO_EDGE);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.CLAMP_TO_EDGE);
		Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.RGBA, Sys.gl.RGBA, Sys.gl.UNSIGNED_BYTE, texture.image);
		//Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, null);
	}
	
	public function set(stage: Int): Void {
		Sys.gl.activeTexture(Sys.gl.TEXTURE0 + stage);
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, texture);
	}
}
