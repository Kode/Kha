package kha;

/**
 * This represents a text font.
 */
interface Font extends Resource {
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
	
	function widthOfCharacters(fontSize: Int, characters: Array<Int>, start: Int, length: Int): Float;

	/**
	 * The base line position.
	 */
	function baseline(fontSize: Int): Float;
}
