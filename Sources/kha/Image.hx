package kha;

import kha.graphics.Texture;

interface Image extends Resource {
	var width(get, null): Int;
	var height(get, null): Int;
	function isOpaque(x: Int, y: Int): Bool;
	function unload(): Void;
}
