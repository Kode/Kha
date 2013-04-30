package kha.cpp;

import kha.graphics.Texture;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Resources/Image.h>
#include <Kt/Graphics/Graphics.h>
')

@:headerClassCode("Kt::Image image; Kt::Texture* texture;")
class Image implements Texture {
	private var tex: Texture = null;
	
	public function new(filename: String) {
		loadImage(filename);
	}
	
	@:functionCode("image = Kt::Image(filename.c_str()); texture = image.Tex(); image.grabTexture(); image = Kt::Image();")
	function loadImage(filename: String) {
		
	}
	
	public var width(get, null): Int;
	public var height(get, null): Int;
	
	@:functionCode("return texture->width();")
	public function get_width(): Int {
		return 0; 
	}
	
	@:functionCode("return texture->height();")
	public function get_height(): Int {
		return 0;
	}
	
	public var realWidth(get, null): Int;
	public var realHeight(get, null): Int;
	
	@:functionCode("return texture->realWidth();")
	public function get_realWidth(): Int {
		return 0;
	}
	
	@:functionCode("return texture->realHeight();")
	public function get_realHeight(): Int {
		return 0;
	}
	
	@:functionCode("
		texture->set(stage);
	")
	public function set(stage: Int): Void {
		
	}
	
	//@:functionCode("return image.At(x, y).Ab() > 0;")
	public function isOpaque(x: Int, y: Int): Bool {
		return true;
	}
	
	//@:functionCode("image = Kt::Image();")
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
