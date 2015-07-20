package kha.graphics1;

import kha.Color;

/**
 * Basic graphical interface.<br>
 * Represent old devices with only pixel pushing operations.
 */
interface Graphics {
	/**
	 * Begin the graphic operations.
	 * You MUST call this.
	 */
	public function begin(): Void;
	
	/**
	 * Terminate all graphical operations and apply them.
	 * You MUST call this at the end.
	 */
	public function end(): Void;
	
	/**
	 * Set the pixel color at a specific position.
	 */
	public function setPixel(x: Int, y: Int, color: Color): Void;
}
