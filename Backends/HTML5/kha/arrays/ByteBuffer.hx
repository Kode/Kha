package kha.arrays;

import js.lib.ArrayBuffer;

@:forward
abstract ByteBuffer(ArrayBuffer) from ArrayBuffer to ArrayBuffer {
	public function new(length: Int) {
		this = new ArrayBuffer(length);
	}
}
