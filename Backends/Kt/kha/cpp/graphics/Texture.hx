package kha.cpp.graphics;

import kha.Image;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Graphics.h>
')

@:headerClassCode("Kt::Texture* texture;")
class Texture implements kha.graphics.Texture {
	public function new(image: Image) {
		
	}
	
	@:functionCode("
		texture->set(stage);
	")
	public function set(stage: Int): Void {
		
	}
	
	@:functionCode("
		return texture->width();
	")
	public function width(): Int {
		return 0;
	}
	
	@:functionCode("
		return texture->height();
	")
	public function height(): Int {
		return 0;
	}
}