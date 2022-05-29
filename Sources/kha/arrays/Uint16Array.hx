package kha.arrays;

@:forward
abstract Uint16Array(ByteArray) from ByteArray to ByteArray {
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.byteLength >> 1;
	}

	public function new(elements: Int) {
		this = ByteArray.make(elements * 2);
	}

	@:arrayAccess
	public inline function get(k: Int): Int {
		return this.getUint16(k * 2);
	}

	@:arrayAccess
	public inline function set(k: Int, v: Int): Int {
		this.setUint16(k * 2, v);
		return get(k);
	}

	public inline function subarray(start: Int, ?end: Int): Uint16Array {
		return this.subarray(start * 2, end != null ? end * 2 : null);
	}
}
