package kha;

interface Image {
	function getWidth() : Int;
	function getHeight() : Int;
	function isOpaque(x : Int, y : Int) : Bool;
}