package kha.arrays;

import kha.Color;
import kha.FastFloat;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;

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
