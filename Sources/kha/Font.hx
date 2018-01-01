package kha;

import haxe.io.Bytes;

extern class Font implements Resource {
	function height(fontSize: Int, ?fontGlyphs: Array<Int>): Float;

	function width(fontSize: Int, str: String, ?fontGlyphs: Array<Int>): Float;
	
	function widthOfCharacters(fontSize: Int, characters: Array<Int>, start: Int, length: Int, ?fontGlyphs: Array<Int>): Float;

	function baseline(fontSize: Int, ?fontGlyphs: Array<Int>): Float;

	function unload(): Void;

	// Portability warning, this works only on some platforms but can usually read ttf
	static function fromBytes(bytes: Bytes): Font;
}
