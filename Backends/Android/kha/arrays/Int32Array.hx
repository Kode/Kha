package kha.arrays;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;

abstract Int32Array(IntBuffer) {
	static inline var elementSize = 4;

	public inline function new(elements: Int) {
		this = ByteBuffer.allocateDirect(elements * elementSize).order(ByteOrder.nativeOrder()).asIntBuffer();
	}

	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.remaining();
	}

	public function set(index: Int, value: Int): Int {
		this.put(index, value);
		return value;
	}

	public inline function get(index: Int): Int {
		return this.get(index);
	}

	public inline function data(): IntBuffer {
		return this;
	}

	@:arrayAccess
	public inline function arrayRead(index: Int): Int {
		return this.get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: Int): Int {
		this.put(index, value);
		return value;
	}

	// public inline function subarray(start: Int, ?end: Int): Int16Array {
	//	return cast this.subarray(start, end);
	// }
}
