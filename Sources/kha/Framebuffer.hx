package kha;

/**
 * A Framebuffer object represents the framebuffer of a kha.Window, which
 * typically contains a color, depth and stencil buffer. It is used to
 * query Graphics interfaces for rendering images which are directly visible.
 */
class Framebuffer implements Canvas {
	var window: Int;
	var graphics1: kha.graphics1.Graphics;
	var graphics2: kha.graphics2.Graphics;
	var graphics4: kha.graphics4.Graphics;

	//**var graphics5: kha.graphics5.Graphics;

	@:noCompletion
	@:noDoc
	public function new(window: Int, g1: kha.graphics1.Graphics, g2: kha.graphics2.Graphics, g4: kha.graphics4.Graphics /*, ?g5: kha.graphics5.Graphics*/) {
		this.window = window;
		this.graphics1 = g1;
		this.graphics2 = g2;
		this.graphics4 = g4;
		// this.graphics5 = g5;
	}

	@:noCompletion
	@:noDoc
	public function init(g1: kha.graphics1.Graphics, g2: kha.graphics2.Graphics, g4: kha.graphics4.Graphics /*, ?g5: kha.graphics5.Graphics*/): Void {
		this.graphics1 = g1;
		this.graphics2 = g2;
		this.graphics4 = g4;
		// this.graphics5 = g5;
	}

	/**
	 * Returns a kha.graphics1.Graphics interface for the framebuffer.
	 */
	public var g1(get, never): kha.graphics1.Graphics;

	function get_g1(): kha.graphics1.Graphics {
		return graphics1;
	}

	/**
	 * Returns a kha.graphics2.Graphics interface for the framebuffer.
	 */
	public var g2(get, never): kha.graphics2.Graphics;

	function get_g2(): kha.graphics2.Graphics {
		return graphics2;
	}

	/**
	 * Returns a kha.graphics4.Graphics interface for the framebuffer.
	 */
	public var g4(get, never): kha.graphics4.Graphics;

	function get_g4(): kha.graphics4.Graphics {
		return graphics4;
	}

	/**
	 * Returns a kha.graphics5.Graphics interface for the framebuffer.
	 */
	/*public var g5(get, never): kha.graphics5.Graphics;

		private function get_g5(): kha.graphics5.Graphics {
			return graphics5;
	}*/
	/**
	 * Returns the width of the framebuffer in pixels.
	 */
	public var width(get, null): Int;

	function get_width(): Int {
		return System.windowWidth(window);
	}

	/**
	 * Returns the height of the framebuffer in pixels.
	 */
	public var height(get, null): Int;

	function get_height(): Int {
		return System.windowHeight(window);
	}
}
