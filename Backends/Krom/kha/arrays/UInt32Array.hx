package kha.arrays;

abstract UInt32Array(js.html.UInt32Array) {
	public inline function new(elements: Int) {
		this = new js.html.UInt32Array(elements);
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}
	
	public inline function set(index: Int, value: Int): Int {
		return this[index] = value;
	}
	
	public inline function get(index: Int): FastFloat {
		return this[index];
	}
	
	public inline function data(): js.html.UInt32Array {
		return this;
	}
}
