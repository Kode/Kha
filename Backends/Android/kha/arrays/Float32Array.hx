package kha.arrays;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

abstract Float32Array(java.NativeArray<Single>) {
	static inline var elementSize = 4;

	public inline function new(elements: Int) {
		this = new java.NativeArray<Single>(elements * elementSize);
	}

	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}

	@:arrayAccess
	public inline function set(index: Int, value: FastFloat): FastFloat {
		this[index] = value;
		return value;
	}

	@:arrayAccess
	public inline function get(index: Int): FastFloat {
		return this[index];
	}

	public inline function data(count: Int): FloatBuffer {
		return FloatBuffer.wrap(this, 0, count);
	}

	// public inline function subarray(start: Int, ?end: Int): Float32Array {
	//	return cast this.subarray(start, end);
	// }
}
