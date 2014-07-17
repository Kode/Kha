package kha;

interface Image extends Canvas extends Resource {
	function isOpaque(x: Int, y: Int): Bool;
	function unload(): Void;
}
