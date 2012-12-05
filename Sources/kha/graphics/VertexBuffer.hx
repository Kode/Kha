package kha.graphics;

interface VertexBuffer {
	function lock(?start: Int, ?count: Int): Array<Float>;
	function unlock(): Void;
	function stride(): Int;
	function size(): Int;
}