package kha.js;

import haxe.io.Bytes;
import js.Browser;
import js.html.ImageElement;
import js.html.Uint8Array;
import kha.graphics.Texture;
import kha.graphics.TextureFormat;

class Image implements Texture {
	public var image: ImageElement;
	
	private static var context : Dynamic;
	private var data : Dynamic;
	
	private var myWidth: Int;
	private var myHeight: Int;
	private var format: TextureFormat;
	
	public static function init() {
		var canvas : Dynamic = Browser.document.createElement("canvas");
		if (canvas != null) {
			context = canvas.getContext("2d");
			canvas.width = 2048;
			canvas.height = 2048;
		}
	}
	
	public function new(width: Int, height: Int, format: TextureFormat) {
		myWidth = width;
		myHeight = height;
		this.format = format;
	}
	
	public static function fromImage(image: ImageElement): Image {
		var img = new Image(image.width, image.height, TextureFormat.RGBA32);
		img.image = image;
		img.createTexture();
		return img;
	}
	
	public var width(get, null): Int;
	public var height(get, null): Int;
	
	public function get_width() : Int {
		return myWidth;
	}
	
	public function get_height() : Int {
		return myHeight;
	}
	
	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;
	
	public function get_realWidth(): Int {
		return myWidth;
	}
	
	public function get_realHeight(): Int {
		return myHeight;
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
		//texture.image = image;
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, texture);
		//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);
		
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.LINEAR);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.CLAMP_TO_EDGE);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.CLAMP_TO_EDGE);
		Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.RGBA, Sys.gl.RGBA, Sys.gl.UNSIGNED_BYTE, image);
		//Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, null);
	}
	
	public function set(stage: Int): Void {
		Sys.gl.activeTexture(Sys.gl.TEXTURE0 + stage);
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, texture);
	}
	
	private var bytes: Bytes;
	
	public function lock(): Bytes {
		bytes = Bytes.alloc(format == TextureFormat.RGBA32 ? 4 * width * height : width * height);
		return bytes;
	}
	
	public function unlock(): Void {
		texture = Sys.gl.createTexture();
		//texture.image = image;
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, texture);
		//Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);
		
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.LINEAR);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.CLAMP_TO_EDGE);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.CLAMP_TO_EDGE);
		Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.LUMINANCE, width, height, 0, Sys.gl.LUMINANCE, Sys.gl.UNSIGNED_BYTE, new Uint8Array(bytes.getData()));
		//Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, null);
		bytes = null;
	}
}
