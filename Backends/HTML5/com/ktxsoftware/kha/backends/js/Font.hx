package com.ktxsoftware.kha.backends.js;

import com.ktxsoftware.kha.FontStyle;

class Font implements com.ktxsoftware.kha.Font {
	public var name : String;
	public var style : FontStyle;
	public var size : Int;
	
	public function new(name : String, style : FontStyle, size : Int) {
		this.name = name;
		this.style = style;
		this.size = size;
	}
	
	public function getHeight() : Float {
		return size;
	}

	public function charWidth(ch : String) : Float {
		return stringWidth(ch);
	}

	public function charsWidth(ch : String, offset : Int, length : Int) : Float {
		return stringWidth(ch.substr(offset, length));
	}

	public function stringWidth(str : String) : Float {
		return Painter.stringWidth(this, str);
	}

	public function getBaselinePosition() : Float {
		return 0;
	}
}