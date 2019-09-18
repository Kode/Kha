package kha.graphics4;

import kha.arrays.Uint32Array;

extern class IndexBuffer {
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false);
	public function delete(): Void;
	public function lock(?start: Int, ?count: Int): Uint32Array;
	public function unlock(?count: Int): Void;
	public function set(): Void;
	public function count(): Int;
}
