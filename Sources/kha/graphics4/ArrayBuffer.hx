package kha.graphics4;
import haxe.io.Float32Array;

extern class ArrayBuffer {
	public function new(indexCount: Int, structureSize: Int, usage: Usage);
	public function lock(): Float32Array;
	public function unlock(): Void;
	public function set(location: AttributeLocation, divisor: Int): Void;
	public function count(): Int;
}
