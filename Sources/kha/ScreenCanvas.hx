package kha;

/**
 * This represents the screen canvas.
 * This is deprecated.
 */
class ScreenCanvas implements Canvas {
	private static var instance: ScreenCanvas = null;
	
	private function new() {
		
	}
	
	/**
	 * Static instance of the ScreenCanvas.
	 */
	public static var the(get, null): ScreenCanvas;
	
	private static function get_the(): ScreenCanvas {
		if (instance == null) instance = new ScreenCanvas();
		return instance;
	}

	/**
	 * The width of the canvas in pixels.
	 */
	public var width(get, null): Int;
	
	private function get_width(): Int {
		return System.windowWidth();
	}
	
	/**
	 * The height of the canvas in pixels.
	 */

	public var height(get, null): Int;
	
	private function get_height(): Int {
		return System.windowHeight();
	}
	
	/**
	 * The Graphics1 interface object.<br>
	 * Basic setPixel operation.
	 */
	public var g1(get, null): kha.graphics1.Graphics;
	
	private function get_g1(): kha.graphics1.Graphics {
		return null;
	}

	/**
	 * The Graphics2 interface object.<br>
	 * Use this for 2D operations.
	 */
	public var g2(get, null): kha.graphics2.Graphics;
	
	private function get_g2(): kha.graphics2.Graphics {
		return null;
	}
	
	/**
	 * The Graphics4 interface object.<br>
	 * Use this for 3D operations.
	 */

	public var g4(get, null): kha.graphics4.Graphics;
	
	private function get_g4(): kha.graphics4.Graphics {
		return null;
	}
}