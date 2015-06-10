package kha;

/**
 * This represents a text font.
 */
interface Font {
	/**
	 * The font name.
	 */
	var name(get, null): String;
	/**
	 * Font style (bold, italic, ect).
	 */
	var style(get, null): FontStyle;
	/**
	 * Font size
	 */
	var size(get, null): Float;
	/**
	 * Font height
	 */
	function getHeight(): Float;
	/**
	 * With of a character in this font
	 * 
 	 * @param ch		The character.
	 */
	function charWidth(ch: String): Float;
	/**
	 * With of a group character in this font.
	 *
	 * @param ch		The characters.
	 * @param offset	The offset before get the 1st character.
	 * @param length	The length to get.
	 */
	function charsWidth(ch: String, offset: Int, length: Int): Float;
	/**
	 * Width of a string with this font.
	 *
	 * @param str		The string to measure.
	 */
	function stringWidth(str: String): Float;
	/**
	 * The base line position.
	 */
	function getBaselinePosition(): Float;
}
