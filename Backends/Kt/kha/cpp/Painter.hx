package kha.cpp;
import kha.Image;

@:cppFileCode('
#include <kha/cpp/Image.h>
#include <Kt/stdafx.h>
#include <Kt/Graphics/Painter.h>

extern Kt::Painter* haxePainter;
')

class Painter extends kha.Painter {
	var tx : Float;
	var ty : Float;
	
	public function new() {
		tx = 0;
		ty = 0;
	}
	
	public override function begin() {
		
	}
	
	public override function end() {
		
	}
	
	public override function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	@:functionCode('
	::kha::cpp::Image_obj* img = dynamic_cast< ::kha::cpp::Image_obj*>(image->__GetRealObject());
	haxePainter->drawImage(img->image, tx + x, ty + y);
	')
	override public function drawImage(image : Image, x : Float, y : Float) : Void {
		
	}
	
	@:functionCode('
	::kha::cpp::Image_obj* img = dynamic_cast< ::kha::cpp::Image_obj*>(image->__GetRealObject());
	haxePainter->drawSubImage(img->image, tx + dx, ty + dy, dw, dh, sx, sy, sw, sh);
	')
	override public function drawImage2(image : kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		
	}
}