package kha.arrays;

import cs.NativeArray;

abstract Float32Array(NativeArray<Float>) {
	public inline function new(elements: Int) {
		this = new NativeArray<Float>(elements);
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}
	
	public function set(index: Int, value: FastFloat): FastFloat {
		this[index] = value;
		return value;
	}
	
	public inline function get(index: Int): FastFloat {
		return this[index];
	}
	
	public inline function data(): NativeArray<Float> {
		return this;
	}
}
