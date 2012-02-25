package com.ktxsoftware.kha.backends.flash;

class Font implements com.ktxsoftware.kha.Font {
	public function new() {
		
	}
	
	public function getHeight() : Float {
		return 10;
	}
	
	public function charWidth(ch : String) : Float {
		return 10;
	}
	
	public function charsWidth(ch : String, offset : Int, length : Int) : Float {
		return 10;
	}
	
	public function stringWidth(str : String) : Float {
		return 10;
	}
	
	public function getBaselinePosition() : Float {
		return 0;
	}
}