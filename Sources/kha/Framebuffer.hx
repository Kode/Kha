package kha;

/**
 * The Framebuffer represents the visible color output buffer.
 */
@:allow(kha.Starter)
class Framebuffer implements Canvas {
	private var windowId: Int;
	private var graphics1: kha.graphics1.Graphics;
	private var graphics2: kha.graphics2.Graphics;
	private var graphics4: kha.graphics4.Graphics;

	/**
	 * Used internally.
	 */
	public function new(windowId: Int, g1: kha.graphics1.Graphics, g2: kha.graphics2.Graphics, g4: kha.graphics4.Graphics) {
		this.windowId = windowId;
		this.graphics1 = g1;
		this.graphics2 = g2;
		this.graphics4 = g4;
	}

	/**
	 * Used internally.
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

	private function get_g1(): kha.graphics1.Graphics {
		return graphics1;
	}

	/**
	 * The Graphics2 interface object.<br>
	 * Use this for 2D operations.
	 */
	public var g2(get, null): kha.graphics2.Graphics;

	private function get_g2(): kha.graphics2.Graphics {
		return graphics2;
	}

	/**
	 * The Graphics4 interface object.<br>
	 * Use this for 3D operations.
	 */
	public var g4(get, null): kha.graphics4.Graphics;

	private function get_g4(): kha.graphics4.Graphics {
		return graphics4;
	}

	/**
	 * The width of the buffer in pixels.
	 */
	public var width(get, null): Int;

	private function get_width(): Int {
		return System.windowWidth(windowId);
	}

	/**
	 * The height of the buffer in pixels.
	 */
	public var height(get, null): Int;

	private function get_height(): Int {
		return System.windowHeight(windowId);
	}
}
