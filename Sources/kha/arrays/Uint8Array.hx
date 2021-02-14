package kha.arrays;

@:forward
abstract Uint8Array(ByteArray) from ByteArray to ByteArray {
	public var length(get, never): Int;

	function get_length(): Int {
		return this.byteLength;
	}

	public function new(elements: Int) {
		this = ByteArray.make(elements);
	}

	@:arrayAccess
	public function get(k: Int): Int {
		return this.getUint8(k);
	}

	@:arrayAccess
	public function set(k: Int, v: Int): Int {
		this.setUint8(k, v);
		return get(k);
	}

	public function subarray(start: Int, ?end: Int): Uint8Array {
		return this.subarray(start, end);
	}
}
