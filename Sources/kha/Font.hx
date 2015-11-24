package kha;

/**
 * This represents a text font.
 */
interface Font {
	/**
	 * Font height
	 */
	function height(fontSize: Int): Float;
	
	/**
	 * Width of a string with this font.
	 *
	 * @param str		The string to measure.
	 */
	function width(fontSize: Int, str: String): Float;
	
	/**
	 * The base line position.
	 */
	function baseline(fontSize: Int): Float;
}
