package kha;

interface Cursor {
	function render(painter: Painter, x: Int, y: Int): Void;
	function update(x: Int, y: Int): Void;
}
