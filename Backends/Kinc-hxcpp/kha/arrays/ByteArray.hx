package kha.arrays;

import cpp.vm.Gc;

class ByteArrayPrivate {
	public var self: ByteBuffer;

	public inline function new(elements: Int = 0) {
		self = ByteBuffer.create();
		if (elements > 0) {
			self.alloc(elements);
		}

		Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
	}

	@:void static function finalize(arr: ByteArrayPrivate): Void {
		arr.self.free();
	}
}

abstract ByteArray(ByteArrayPrivate) {
	public var buffer(get, never): ByteBuffer;

	inline function get_buffer(): ByteBuffer {
		return this.self;
	}

	public var byteLength(get, never): Int;

	inline function get_byteLength(): Int {
		return this.self.byteLength;
	}

	public var byteOffset(get, never): Int;

	inline function get_byteOffset(): Int {
		return 0;
	}

	public inline function new(buffer: ByteBuffer, ?byteOffset: Int, ?byteLength: Int): Void {
		this = new ByteArrayPrivate(byteLength != null ? byteLength : buffer.byteLength);
	}

	public static inline function make(byteLength: Int): ByteArray {
		return new ByteArray(ByteBuffer.create(), 0, byteLength);
	}

	public function getInt8(byteOffset: Int): Int {
		return 0;
	}

	public function getUint8(byteOffset: Int): Int {
		return 0;
	}

	public function getInt16(byteOffset: Int): Int {
		return 0;
	}

	public function getUint16(byteOffset: Int): Int {
		return 0;
	}

	public function getInt32(byteOffset: Int): Int {
		return 0;
	}

	public function getUint32(byteOffset: Int): Int {
		return 0;
	}

	public function getFloat32(byteOffset: Int): FastFloat {
		return 0;
	}

	public function getFloat64(byteOffset: Int): Float {
		return 0;
	}

	public function setInt8(byteOffset: Int, value: Int): Void {}

	public function setUint8(byteOffset: Int, value: Int): Void {}

	public function setInt16(byteOffset: Int, value: Int): Void {}

	public function setUint16(byteOffset: Int, value: Int): Void {}

	public function setInt32(byteOffset: Int, value: Int): Void {}

	public function setUint32(byteOffset: Int, value: Int): Void {}

	public function setFloat32(byteOffset: Int, value: FastFloat): Void {}

	public function setFloat64(byteOffset: Int, value: Float): Void {}

	public function getInt16LE(byteOffset: Int): Int {
		return 0;
	}

	public function getUint16LE(byteOffset: Int): Int {
		return 0;
	}

	public function getInt32LE(byteOffset: Int): Int {
		return 0;
	}

	public function getUint32LE(byteOffset: Int): Int {
		return 0;
	}

	public function getFloat32LE(byteOffset: Int): FastFloat {
		return 0;
	}

	public function getFloat64LE(byteOffset: Int): Float {
		return 0;
	}

	public function setInt16LE(byteOffset: Int, value: Int): Void {}

	public function setUint16LE(byteOffset: Int, value: Int): Void {}

	public function setInt32LE(byteOffset: Int, value: Int): Void {}

	public function setUint32LE(byteOffset: Int, value: Int): Void {}

	public function setFloat32LE(byteOffset: Int, value: FastFloat): Void {}

	public function setFloat64LE(byteOffset: Int, value: Float): Void {}

	public function getInt16BE(byteOffset: Int): Int {
		return 0;
	}

	public function getUint16BE(byteOffset: Int): Int {
		return 0;
	}

	public function getInt32BE(byteOffset: Int): Int {
		return 0;
	}

	public function getUint32BE(byteOffset: Int): Int {
		return 0;
	}

	public function getFloat32BE(byteOffset: Int): FastFloat {
		return 0;
	}

	public function getFloat64BE(byteOffset: Int): Float {
		return 0;
	}

	public function setInt16BE(byteOffset: Int, value: Int): Void {}

	public function setUint16BE(byteOffset: Int, value: Int): Void {}

	public function setInt32BE(byteOffset: Int, value: Int): Void {}

	public function setUint32BE(byteOffset: Int, value: Int): Void {}

	public function setFloat32BE(byteOffset: Int, value: FastFloat): Void {}

	public function setFloat64BE(byteOffset: Int, value: Float): Void {}

	public function subarray(start: Int, ?end: Int): ByteArray {
		return null;
	}
}
