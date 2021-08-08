package kha.arrays;

import js.lib.ArrayBuffer;

@:forward
abstract ByteBuffer(ArrayBuffer) from ArrayBuffer to ArrayBuffer {
	public static function create(length: Int): ByteBuffer {
		return new ByteBuffer(length);
	}

	function new(length: Int) {
		this = new ArrayBuffer(length);
	}
}
