package kha.arrays;

import kha.FastFloat;

abstract Float32Array(js.html.Float32Array) {
	public inline function new(elements: Int) {
		this = new js.html.Float32Array(elements);
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		return this[index] = value;
	}
	
	public inline function get(index: Int): FastFloat {
		return this[index];
	}
	
	public inline function data(): js.html.Float32Array {
		return this;
	}
}
