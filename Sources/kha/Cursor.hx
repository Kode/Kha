package kha;

interface Cursor {
	var clickX(get,never) : Int;
	var clickY(get,never) : Int;
	var width(get,never) : Int;
	var height(get,never) : Int;
	function render(painter: Painter, x: Int, y: Int): Void;
	function update(x : Int, y : Int): Void;
}
