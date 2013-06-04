package kha.cpp;

import kha.cpp.graphics.TextureUnit;
import kha.graphics.Texture;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Texture* texture;")
class Image implements Texture {
	private var tex: Texture = null;
	
	public function new(filename: String) {
		loadImage(filename);
	}
	
	@:functionCode("texture = new Kore::Texture(filename.c_str());")
	function loadImage(filename: String) {
		
	}
	
	public var width(get, null): Int;
	public var height(get, null): Int;
	
	@:functionCode("return texture->width;")
	public function get_width(): Int {
		return 0; 
	}
	
	@:functionCode("return texture->height;")
	public function get_height(): Int {
		return 0;
	}
	
	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;
	
	@:functionCode("return texture->texWidth;")
	public function get_realWidth(): Int {
		return 0;
	}
	
	@:functionCode("return texture->texHeight;")
	public function get_realHeight(): Int {
		return 0;
	}
	
	@:functionCode("
		texture->set(unit->unit);
	")
	public function set(unit: TextureUnit): Void {
		
	}
	
	//@:functionCode("return image.At(x, y).Ab() > 0;")
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}
	
	@:functionCode("delete texture; texture = nullptr;")
	public function unload(): Void {
		
	}
	
	public function getTexture(): Texture {
		return tex;
	}
	
	public function setTexture(texture: Texture): Void {
		this.tex = texture;
	}
}
