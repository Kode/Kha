package kha;

/**
 * This represents a text font.
 */
interface Font {
	/**
	 * Font height
	 */
	function getHeight(fontSize: Int): Float;
	
	/**
	 * With of a character in this font
	 * 
 	 * @param ch		The character.
	 */
	function charWidth(fontSize: Int, ch: String): Float;
	
	/**
	 * With of a group character in this font.
	 *
	 * @param ch		The characters.
	 * @param offset	The offset before get the 1st character.
	 * @param length	The length to get.
	 */
	function charsWidth(fontSize: Int, ch: String, offset: Int, length: Int): Float;
	
	/**
	 * Width of a string with this font.
	 *
	 * @param str		The string to measure.
	 */
	function stringWidth(fontSize: Int, str: String): Float;
	
	/**
	 * The base line position.
	 */
	function getBaselinePosition(fontSize: Int): Float;
}
