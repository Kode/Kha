package kha;

interface Image implements Resource {
	function getWidth() : Int;
	function getHeight() : Int;
	function isOpaque(x : Int, y : Int) : Bool;
	function unload(): Void;
}