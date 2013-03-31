package kha.js.graphics;

import kha.Image;

class Texture implements kha.graphics.Texture {
	private var image: Image;
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
	
	public function new(image: Image) {
		texture = Sys.gl.createTexture();
		texture.image = cast(image, kha.js.Image).image;
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
	
	public function width(): Int {
		return image.getWidth();
	}
	
	public function height(): Int {
		return image.getHeight();
	}
}