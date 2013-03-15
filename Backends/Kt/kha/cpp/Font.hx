package kha.cpp;

import kha.FontStyle;

@:cppFileCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Font.h>
')

class Font implements kha.Font {
	public var name: String;
	public var style: FontStyle;
	public var size: Int;
	
	public function new(name: String, style: FontStyle, size: Int) {
		this.name = name;
		this.style = style;
		this.size = size;
	}
	
	public function getHeight(): Float {
		return size;
	}
	
	public function charWidth(ch: String): Float {
		return stringWidth(ch);
	}
	
	public function charsWidth(ch: String, offset: Int, length: Int): Float {
		return stringWidth(ch.substr(offset, length));
	}
	
	@:functionCode("
		if (Kt::fonts.find(Kt::pair<Kt::Text, int>(name.c_str(), size)) == Kt::fonts.end()) Kt::fonts[Kt::pair<Kt::Text, int>(name.c_str(), size)] = new Kt::Font(name.c_str(), size);
		return Kt::fonts[Kt::pair<Kt::Text, int>(name.c_str(), size)]->width(str.c_str());
	")
	public function stringWidth(str: String): Float {
		return 10;
	}
	
	public function getBaselinePosition() : Float {
		return 5;
	}
}