package kha;

/**
 * A generic interface for a Cursor.
 */
interface Cursor {
	/**
	 * The X position.
	 */
	var clickX(get, never): Int;
	/**
	 * The Y position.
	 */
	var clickY(get, never): Int;
	/**
	 * The cursor width.
	 */
	var width(get, never): Int;
	/**
	 * The cursor height.
	 */
	var height(get, never): Int;
	/**
	 * Render the cursor on screen.
	 * 
	 * @param g		The graphics2 instance to render.
	 * @param x		The X position of the cursor.
	 * @param y		The Y position of the cursor.
	 */
	function render(g: kha.graphics2.Graphics, x: Int, y: Int): Void;
	/**
	 * Update the cursor.
	 * 
	 * @param x		The X position of the cursor.
	 * @param y		The Y position of the cursor.
	 */
	function update(x: Int, y: Int): Void;
}
