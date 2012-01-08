package com.ktxsoftware.kha.backends.cpp;

class Image implements com.ktxsoftware.kha.Image {
	public function new(filename : String) {
		
	}
	
	public function getWidth() : Int {
		return 100;
	}
	
	public function getHeight() : Int {
		return 100;
	}
	
	public function isAlpha(x : Int, y : Int) : Bool {
		return true;
	}
}