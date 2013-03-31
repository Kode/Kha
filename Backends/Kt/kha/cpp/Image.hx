package kha.cpp;
import kha.graphics.Texture;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Resources/Image.h>
#include <Kt/Graphics/Graphics.h>
')

@:headerClassCode("Kt::Image image; Kt::Texture* texture;")
class Image implements kha.Image {
	private var texture: Texture = null;
	
	public function new(filename: String) {
		loadImage(filename);
	}
	
	@:functionCode("image = Kt::Image(filename.c_str()); texture = image.Tex(); image.grabTexture(); image = Kt::Image();")
	function loadImage(filename: String) {
		
	}
	
	@:functionCode("return texture->width();")
	public function getWidth(): Int {
		return 0; 
	}
	
	@:functionCode("return texture->height();")
	public function getHeight(): Int {
		return 0;
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
		return texture;
	}
	
	public function setTexture(texture: Texture): Void {
		this.texture = texture;
	}
}
