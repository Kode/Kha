package kha;

interface Font {
	var name(get, null): String;
	var style(get, null): FontStyle;
	var size(get, null): Float;
	function getHeight(): Float;
	function charWidth(ch: String): Float;
	function charsWidth(ch: String, offset: Int, length: Int): Float;
	function stringWidth(str: String): Float;
	function getBaselinePosition(): Float;
}
