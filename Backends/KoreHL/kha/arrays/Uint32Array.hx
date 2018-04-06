package kha.arrays;

abstract Uint32Array(haxe.io.Bytes) {
	
	public inline function new(elements: Int) {
		this = haxe.io.Bytes.alloc(elements * 4);
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return Std.int(this.length / 4);
	}
	
	public inline function set(index: Int, value: Int): Int {
		this.setInt32(index * 4, value);
		return value;
	}
	
	public inline function get(index: Int): Int {
		return this.getInt32(index * 4);
	}

	@:arrayAccess
	public inline function arrayRead(index: Int): Int {
		return get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: Int): Int {
		return set(index, value);
	}
}
