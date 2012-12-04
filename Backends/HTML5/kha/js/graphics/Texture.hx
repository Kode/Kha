package kha.js.graphics;

import kha.Image;

class Texture implements kha.graphics.Texture {
	private var image: Image;
	private var texture: Dynamic;
	
	public function new(image: Image) {
		texture = Sys.gl.createTexture();
		texture.image = cast(image, kha.js.Image).image;
		Sys.gl.bindTexture(Sys.gl.TEXTURE_2D, texture);
		Sys.gl.pixelStorei(Sys.gl.UNPACK_FLIP_Y_WEBGL, true);
		Sys.gl.texImage2D(Sys.gl.TEXTURE_2D, 0, Sys.gl.RGBA, Sys.gl.RGBA, Sys.gl.UNSIGNED_BYTE, texture.image);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.LINEAR);
		Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR_MIPMAP_LINEAR);
		Sys.gl.generateMipmap(Sys.gl.TEXTURE_2D);
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