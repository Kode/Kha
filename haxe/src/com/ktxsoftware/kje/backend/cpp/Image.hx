package com.ktxsoftware.kje.backend.cpp;

class Image implements com.ktxsoftware.kje.Image {
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