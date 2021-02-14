package kha.arrays;

@:forward
abstract Float64Array(ByteArray) from ByteArray to ByteArray {
	public var length(get, never): Int;

	function get_length(): Int {
		return this.byteLength >> 3;
	}

	public function new(elements: Int) {
		this = ByteArray.make(elements * 8);
	}

	@:arrayAccess
	public function get(k: Int): Float {
		return this.getFloat64(k * 8);
	}

	@:arrayAccess
	public function set(k: Int, v: Float): Float {
		this.setFloat64(k * 8, v);
		return v;
	}

	public function subarray(start: Int, ?end: Int): Float64Array {
		return this.subarray(start * 8, end != null ? end * 8 : end);
	}
}
