package kha.cpp;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Resources/Image.h>
')

@:headerClassCode("Kt::Image image;")
class Image implements kha.Image {
	public function new(filename : String) {
		loadImage(filename);
	}
	
	@:functionCode("image = Kt::Image(filename.c_str());")
	function loadImage(filename : String) {
		
	}
	
	@:functionCode("return (int)image.Width();")
	public function getWidth() : Int {
		return 0; 
	}
	
	@:functionCode("return (int)image.Height();")
	public function getHeight() : Int {
		return 0;
	}
	
	public function isOpaque(x : Int, y : Int) : Bool {
		return true;
	}
}