package kha.arrays;

import java.NativeArray;

abstract Int16Array(NativeArray<java.Int16>) {
	public inline function new(elements: Int) {
		this = new NativeArray<java.Int16>(elements);
	}

	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}

	public inline function set(index: Int, value: Int): Int {
		return this[index] = value;
	}

	public inline function get(index: Int): Int {
		return this[index];
	}

	public inline function data(): NativeArray<java.Int16> {
		return this;
	}

	@:arrayAccess
	public inline function arrayRead(index: Int): Int {
		return this[index];
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: Int): Int {
		return this[index] = value;
	}

	// public inline function subarray(start: Int, ?end: Int): Int16Array {
	//	return cast this.subarray(start, end);
	// }
}
