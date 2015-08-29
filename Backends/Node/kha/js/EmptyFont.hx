package kha.js;

import kha.Font;
import kha.FontStyle;

class EmptyFont implements Font {
	private var myName: String;
	private var myStyle: FontStyle;
	private var mySize: Float;
	
	public function new(name: String, style: FontStyle, size: Float) {
		myName = name;
		myStyle = style;
		mySize = size;
	}
	
	public var name(get, null): String;
	
	private function get_name(): String {
		return myName;
	}
	
	public var style(get, null): FontStyle;
	
	private function get_style(): FontStyle {
		return myStyle;
	}
	
	public var size(get, null): Float;
	
	private function get_size(): Float {
		return mySize;
	}
	
	public function getHeight(): Float {
		return mySize;
	}

	public function charWidth(ch: String): Float {
		return mySize / 2;
	}

	public function charsWidth(ch: String, offset: Int, length: Int): Float {
		return mySize / 2 * length;
	}

	public function stringWidth(str: String): Float {
		return mySize / 2 * str.length;
	}

	public function getBaselinePosition(): Float {
		return mySize / 3 * 2;
	}
}
