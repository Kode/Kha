package kha.arrays;

import cs.NativeArray;

abstract Int32Array(NativeArray<Int>) {
	public inline function new(elements: Int) {
		this = new NativeArray<Int>(elements);
	}

	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}

	@:arrayAccess
	public function set(index: Int, value: Int): Int {
		this[index] = value;
		return value;
	}

	@:arrayAccess
	public inline function get(index: Int): Int {
		return this[index];
	}

	public inline function data(): NativeArray<Int> {
		return this;
	}
}
