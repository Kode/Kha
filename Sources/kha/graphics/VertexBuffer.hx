package kha.graphics;

interface VertexBuffer {
	function lock(?start: Int, ?count: Int): Array<Float>;
	function unlock(): Void;
	function count(): Int;
	function stride(): Int;
}