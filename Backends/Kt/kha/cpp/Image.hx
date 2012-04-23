package kha.cpp;

class Image implements kha.Image {
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