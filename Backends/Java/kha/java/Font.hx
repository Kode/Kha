package kha.java;

import kha.FontStyle;

class Font implements kha.Font {
	public function new(name : String, style : FontStyle, size : Int) {
		
	}
	
	public function getHeight() : Float {
		return 10;
	}
	
	public function charWidth(ch : String) : Float {
		return 5;
	}
	
	public function charsWidth(ch : String, offset : Int, length : Int) : Float {
		return 150;
	}
	
	public function stringWidth(str : String) : Float {
		return 150;
	}
	
	public function getBaselinePosition() : Float {
		return 0;
	}
}