package kha;

/**
 * Interface for a generic Canvas with different APIs,<br>
 * that can be used to draw graphics.
 */
@:allow(kha.Starter)
interface Canvas {
	/**
	 * The width of the canvas in pixels.
	 */
	var width(get, null): Int;
	/**
	 * The height of the canvas in pixels.
	 */
	var height(get, null): Int;
	/**
	 * The Graphics1 interface object.<br>
	 * Basic setPixel operation.
	 */
	var g1(get, null): kha.graphics1.Graphics;
	/**
	 * The Graphics2 interface object.<br>
	 * Use this for 2D operations.
	 */
	var g2(get, null): kha.graphics2.Graphics;
	/**
	 * The Graphics4 interface object.<br>
	 * Use this for 3D operations.
	 */
	var g4(get, null): kha.graphics4.Graphics;
}
