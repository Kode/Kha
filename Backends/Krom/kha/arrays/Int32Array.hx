package kha.arrays;

abstract Int32Array(js.lib.Int32Array) {
	public inline function new(elements: Int) {
		this = new js.lib.Int32Array(elements);
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

	public inline function data(): js.lib.Int32Array {
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

	public inline function subarray(start: Int, ?end: Int): Int32Array {
		return cast this.subarray(start, end);
	}
}
