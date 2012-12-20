package kha.cpp;

import kha.Image;
import kha.FontStyle;

@:cppFileCode('
#include <kha/cpp/Image.h>
#include <Kt/stdafx.h>
#include <Kt/Graphics/Painter.h>
#include <Kt/Graphics/Font.h>

extern Kt::Painter* haxePainter;
')

class Painter extends kha.Painter {
	var tx: Float;
	var ty: Float;
	var font: Font;
	var r: Int;
	var g: Int;
	var b: Int;
	
	public function new() {
		tx = 0;
		ty = 0;
		font = new Font("Arial", new FontStyle(false, false, false), 12);
	}
	
	public override function begin() {
		
	}
	
	public override function end() {
		
	}
	
	public override function translate(x: Float, y: Float) {
		tx = x;
		ty = y;
	}
	
	@:functionCode('
	::kha::cpp::Image_obj* img = dynamic_cast< ::kha::cpp::Image_obj*>(image->__GetRealObject());
	haxePainter->drawImage(img->texture, tx + x, ty + y);
	')
	override public function drawImage(image: Image, x: Float, y: Float) : Void {
		
	}
	
	@:functionCode('
	::kha::cpp::Image_obj* img = dynamic_cast< ::kha::cpp::Image_obj*>(image->__GetRealObject());
	haxePainter->drawSubImage(img->texture, tx + dx, ty + dy, dw, dh, sx, sy, sw, sh);
	')
	override public function drawImage2(image: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float) {
		
	}
	
	override public function setColor(r: Int, g: Int, b: Int): Void {
		this.r = r;
		this.g = g;
		this.b = b;
	}
	
	override public function setFont(font: kha.Font): Void {
		this.font = cast(font, Font);
	}
	
	@:functionCode('
	Kt::Text fontName = font->name.c_str();
	int fontSize = font->size;
	if (Kt::fonts.find(Kt::pair<Kt::Text, int>(fontName, fontSize)) == Kt::fonts.end()) Kt::fonts[Kt::pair<Kt::Text, int>(fontName, fontSize)] = new Kt::Font(fontName, fontSize);
	Kt::fonts[Kt::pair<Kt::Text, int>(fontName, fontSize)]->render(haxePainter, text.c_str(), x + tx, y + ty, Kt::Color(r, g, b));	
	')
	override public function drawString(text: String, x: Float, y: Float): Void {
		
	}
	
	@:functionCode('
	haxePainter->drawLine(x1, y1, x2, y2, Kt::Color(r, g, b));
	')
	override public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float): Void {
		
	}
}