package kha;

import kha.graphics.Texture;

interface Image extends Resource {
	function getWidth(): Int;
	function getHeight(): Int;
	function isOpaque(x: Int, y: Int): Bool;
	function unload(): Void;
	
	function getTexture(): Texture;
	function setTexture(texture: Texture): Void;
}
