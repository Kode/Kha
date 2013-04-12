package kha.flash.graphics;

class Texture implements kha.graphics.Texture {
	private var texture: flash.display3D.textures.Texture;
	private var myWidth: Int;
	private var myHeight: Int;
	
	public function new(texture: flash.display3D.textures.Texture, width: Int, height: Int) {
		this.texture = texture;
		myWidth = width;
		myHeight = height;
	}
	
	public function set(stage: Int): Void {
		Starter.context.setTextureAt(stage, texture);
	}
	
	public function width(): Int {
		return myWidth;
	}
	
	public function height(): Int {
		return myHeight;
	}
}
