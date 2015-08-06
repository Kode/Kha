package kha.arrays;

class Float32Array {
	private var buffer: ArrayBuffer;
	private var byteOffset: Int;
	private var length: Int;
	
	private function new(buffer: ArrayBuffer, byteOffset: Int, length: Int) {
		this.buffer = buffer;
		this.byteOffset = byteOffset;
		this.length = length;
	}
	
	public static function fromLength(length: Int): Float32Array {
		return new Float32Array(new ArrayBuffer(length * 4), 0, length);
	}

	public static function fromArray(array: Float32Array): Float32Array {
		return new Float32Array(array.buffer, array.byteOffset, array.length);
	}

	public static function fromBuffer(buffer: ArrayBuffer, byteOffset: Int, length: Int): Float32Array {
		return new Float32Array(buffer, byteOffset, length);
	}
}
