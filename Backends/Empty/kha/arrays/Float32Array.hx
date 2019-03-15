package kha.arrays;

import kha.FastFloat;

abstract Float32Array(Dynamic) {
	public inline function new(elements: Int) {
		this = null;
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return 0;
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		return 0;
	}
	
	public inline function get(index: Int): FastFloat {
		return 0;
	}
	
	public inline function data(): Dynamic {
		return this;
	}

	@:arrayAccess
	public inline function arrayRead(index: Int): FastFloat {
		return 0;
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: FastFloat): FastFloat {
		return 0;
	}

	public inline function subarray(start: Int, ?end: Int): Float32Array {
		return this;
	}
}
