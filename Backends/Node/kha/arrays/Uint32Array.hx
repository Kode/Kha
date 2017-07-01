package kha.arrays;

abstract Uint32Array(js.html.Uint32Array) {
	public inline function new(elements: Int) {
		this = new js.html.Uint32Array(elements);
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
	
	public inline function data(): js.html.Uint32Array {
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

	public inline function subarray(start: Int, ?end: Int): Uint32Array {
		return cast this.subarray(start, end);
	}
}
