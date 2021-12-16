package kha.arrays;

abstract ByteBuffer(java.NativeArray<java.types.Int8>) {
	public inline function new(size: Int) {
		this = new java.NativeArray<java.types.Int8>(size);
	}

	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}

	@:arrayAccess
	public inline function set(index: Int, value: java.types.Int8): java.types.Int8 {
		this[index] = value;
		return value;
	}

	@:arrayAccess
	public inline function get(index: Int): java.types.Int8 {
		return this[index];
	}
}
