package kha;

class ScreenCanvas implements Canvas {
	private static var instance: ScreenCanvas = null;
	
	private function new() {
		
	}
	
	public static var the(get, null): ScreenCanvas;
	
	private static function get_the(): ScreenCanvas {
		if (instance == null) instance = new ScreenCanvas();
		return instance;
	}

	public var width(get, null): Int;
	
	private function get_width(): Int {
		return System.windowWidth();
	}
	
	public var height(get, null): Int;
	
	private function get_height(): Int {
		return System.windowHeight();
	}
	
	public var g1(get, null): kha.graphics1.Graphics;
	
	private function get_g1(): kha.graphics1.Graphics {
		return null;
	}

	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		return null;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	
	private function get_g4(): kha.graphics4.Graphics {
		return null;
	}
}
