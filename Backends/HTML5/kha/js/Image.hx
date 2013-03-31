package kha.js;

import js.Dom;
import kha.graphics.Texture;

class Image implements kha.Image {
	public var image: js.Image;
	private var tex: Texture = null;
	
	private static var context : Dynamic;
	private var data : Dynamic;
	
	public static function init() {
		var canvas : Dynamic = js.Lib.document.createElement("canvas");
		if (canvas != null) {
			context = canvas.getContext("2d");
			canvas.width = 2048;
			canvas.height = 2048;
		}
	}
	
	public function new(image : js.Image) {
		this.image = image;
	}
	
	public function getWidth() : Int {
		return image.width;
	}
	
	public function getHeight() : Int {
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
	
	public function setTexture(texture: Texture): Void {
		tex = texture;
	}
	
	public function getTexture(): Texture {
		return tex;
	}
}
