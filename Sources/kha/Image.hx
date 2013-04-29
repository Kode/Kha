package kha;

interface Image extends Resource {
	function getWidth() : Int;
	function getHeight() : Int;
	function isOpaque(x : Int, y : Int) : Bool;
	function unload(): Void;
}