package kha.arrays;

@:forward
abstract Float32Array(ByteArray) from ByteArray to ByteArray {
	public var length(get, never): Int;

	function get_length(): Int {
		return this.byteLength >> 2;
	}

	public function new(elements: Int) {
		this = ByteArray.make(elements * 4);
	}

	@:arrayAccess
	public function get(k: Int): FastFloat {
		return this.getFloat32(k * 4);
	}

	@:arrayAccess
	public function set(k: Int, v: FastFloat): FastFloat {
		this.setFloat32(k * 4, v);
		return v;
	}

	public function subarray(start: Int, ?end: Int): Float32Array {
		return this.subarray(start * 4, end != null ? end * 4 : end);
	}
}
