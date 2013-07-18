package kha.js;

import kha.FontStyle;

class Font implements kha.Font {
	public var myName: String;
	public var myStyle: FontStyle;
	public var mySize: Float;
	
	public function new(name: String, style: FontStyle, size: Float) {
		myName = name;
		myStyle = style;
		mySize = size;
	}
	
	public var name(get, null): String;
	public var style(get, null): FontStyle;
	public var size(get, null): Float;
	
	public function get_name(): String {
		return myName;
	}
	
	public function get_style(): FontStyle {
		return myStyle;
	}
	
	public function get_size(): Float {
		return mySize;
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

	public function stringWidth(str: String): Float {
		return Painter.stringWidth(this, str);
	}

	public function getBaselinePosition(): Float {
		return 0;
	}
}
