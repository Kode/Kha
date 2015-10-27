package kha;

/**
 * The FrameBuffer represents the current graphical status of the application,<br>
 * you can get references to different graphical APIs,<br>
 * that can be used to draw graphics.
 */
@:allow(kha.Starter)
class Framebuffer implements Canvas {
	/**
	 * The Graphics1 interface object.<br>
	 * Basic setPixel operation.
	 */
	private var graphics1: kha.graphics1.Graphics;
	/**
	 * The Graphics2 interface object.<br>
	 * Use this for 2D operations.
	 */
	private var graphics2: kha.graphics2.Graphics;
	/**
	 * The Graphics4 interface object.<br>
	 * Use this for 3D operations.
	 */
	private var graphics4: kha.graphics4.Graphics;

	/**
	 * Create a new frame buffer object instance.
	 * 
	 * @param g1		The Graphics1 object.
 	 * @param g2		The Graphics2 object.
	 * @param g4		The Graphics4 object.
	 */
	public function new(g1: kha.graphics1.Graphics, g2: kha.graphics2.Graphics, g4: kha.graphics4.Graphics) {
		this.graphics1 = g1;
		this.graphics2 = g2;
		this.graphics4 = g4;
	}

	/**
	 * Initialize a new frame buffer object instance.
	 * 
	 * @param g1		The Graphics1 object.
 	 * @param g2		The Graphics2 object.
	 * @param g4		The Graphics4 object.
	 */
	public function init(g1: kha.graphics1.Graphics, g2: kha.graphics2.Graphics, g4: kha.graphics4.Graphics): Void {
		this.graphics1 = g1;
		this.graphics2 = g2;
		this.graphics4 = g4;
	}
	
	/**
	 * The Graphics1 interface object.<br>
	 * Basic setPixel operation.
	 */
	public var g1(get, null): kha.graphics1.Graphics;

	/**
	 * Return the Graphics1 interface object.<br>
	 * Basic setPixel operation.
	 */
	private function get_g1(): kha.graphics1.Graphics {
		return graphics1;
	}

	/**
	 * The Graphics2 interface object.<br>
	 * Use this for 2D operations.
	 */
	public var g2(get, null): kha.graphics2.Graphics;

	/**
	 * Return the Graphics2 interface object.<br>
	 * Use this for 2D operations.
	 */
	private function get_g2(): kha.graphics2.Graphics {
		return graphics2;
	}

	/**
	 * The Graphics4 interface object.<br>
	 * Use this for 3D operations.
	 */
	public var g4(get, null): kha.graphics4.Graphics;

	/**
	 * Return the Graphics4 interface object.<br>
	 * Use this for 3D operations.
	 */	
	private function get_g4(): kha.graphics4.Graphics {
		return graphics4;
	}

	/**
	 * The width of the buffer in pixels.
	 */
	public var width(get, null): Int;

	/**
	 * Return the width of the buffer in pixels.
	 */
	private function get_width(): Int {
		return System.pixelWidth;
	}

	/**
	 * The height of the buffer in pixels.
	 */
	public var height(get, null): Int;

	/**
	 * Return the height of the buffer in pixels.
	 */
	private function get_height(): Int {
		return System.pixelHeight;
	}
}
