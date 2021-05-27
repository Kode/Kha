package kha.arrays;

@:forward
abstract Int32Array(ByteArray) from ByteArray to ByteArray {
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.byteLength >> 2;
	}

	public function new(elements: Int) {
		this = ByteArray.make(elements * 4);
	}

	@:arrayAccess
	public inline function get(k: Int): Int {
		return this.getInt32(k * 4);
	}

	@:arrayAccess
	public inline function set(k: Int, v: Int): Int {
		this.setInt32(k * 4, v);
		return get(k);
	}

	public inline function subarray(start: Int, ?end: Int): Int32Array {
		return this.subarray(start * 4, end != null ? end * 4 : null);
	}
}
