package kha.js.graphics;

import kha.Image;

class Texture implements kha.graphics.Texture {
	private var image: Image;
	private var texture: Dynamic;
	
	public function new(image: Image) {
		texture = System.gl.createTexture();
		texture.image = cast(image, kha.js.Image).image;
		Sys.gl.bindTexture(System.gl.TEXTURE_2D, texture);
		Sys.gl.pixelStorei(System.gl.UNPACK_FLIP_Y_WEBGL, true);
		Sys.gl.texImage2D(System.gl.TEXTURE_2D, 0, System.gl.RGBA, System.gl.RGBA, System.gl.UNSIGNED_BYTE, texture.image);
		Sys.gl.texParameteri(System.gl.TEXTURE_2D, System.gl.TEXTURE_MAG_FILTER, System.gl.LINEAR);
		Sys.gl.texParameteri(System.gl.TEXTURE_2D, System.gl.TEXTURE_MIN_FILTER, System.gl.LINEAR_MIPMAP_LINEAR);
		Sys.gl.generateMipmap(System.gl.TEXTURE_2D);
		Sys.gl.bindTexture(System.gl.TEXTURE_2D, null);
	}
	
	public function set(stage: Int): Void {
		Sys.gl.activeTexture(Sys.gl.TEXTURE0 + stage);
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, tex);
	}
	
	public function width(): Int {
		return image.getWidth();
	}
	
	public function height(): Int {
		return image.getHeight();
	}
}