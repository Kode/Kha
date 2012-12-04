package kha.graphics;

interface IndexBuffer {
	function lock(): Array<Int>;
	function unlock(): Void;
	function set(): Void;
}