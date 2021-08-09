package kha.arrays;

class ByteArrayPrivate {
	public var self: ByteBuffer;

	public inline function new(elements: Int = 0) {
		self = Float32ArrayData.create();
		if (elements > 0) {
			self.alloc(elements);
		}

		Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
	}

	@:void static function finalize(arr: Float32ArrayPrivate): Void {
		arr.self.free();
	}
}

abstract ByteArray(ByteArrayPrivate) {
	var buffer(get, never): ByteBuffer;

	var byteLength(get, never): Int;

	var byteOffset(get, never): Int;

	public inline function new(buffer: ByteArray, ?byteOffset: Int, ?byteLength: Int): Void;

	public static inline function make(byteLength: Int): ByteArray {
		this = new ByteArrayPrivate(byteLength);
	}

	function getInt8(byteOffset: Int): Int;

	function getUint8(byteOffset: Int): Int;

	function getInt16(byteOffset: Int): Int;

	function getUint16(byteOffset: Int): Int;

	function getInt32(byteOffset: Int): Int;

	function getUint32(byteOffset: Int): Int;

	function getFloat32(byteOffset: Int): FastFloat;

	function getFloat64(byteOffset: Int): Float;

	function setInt8(byteOffset: Int, value: Int): Void;

	function setUint8(byteOffset: Int, value: Int): Void;

	function setInt16(byteOffset: Int, value: Int): Void;

	function setUint16(byteOffset: Int, value: Int): Void;

	function setInt32(byteOffset: Int, value: Int): Void;

	function setUint32(byteOffset: Int, value: Int): Void;

	function setFloat32(byteOffset: Int, value: FastFloat): Void;

	function setFloat64(byteOffset: Int, value: Float): Void;

	function getInt16LE(byteOffset: Int): Int;

	function getUint16LE(byteOffset: Int): Int;

	function getInt32LE(byteOffset: Int): Int;

	function getUint32LE(byteOffset: Int): Int;

	function getFloat32LE(byteOffset: Int): FastFloat;

	function getFloat64LE(byteOffset: Int): Float;

	function setInt16LE(byteOffset: Int, value: Int): Void;

	function setUint16LE(byteOffset: Int, value: Int): Void;

	function setInt32LE(byteOffset: Int, value: Int): Void;

	function setUint32LE(byteOffset: Int, value: Int): Void;

	function setFloat32LE(byteOffset: Int, value: FastFloat): Void;

	function setFloat64LE(byteOffset: Int, value: Float): Void;

	function getInt16BE(byteOffset: Int): Int;

	function getUint16BE(byteOffset: Int): Int;

	function getInt32BE(byteOffset: Int): Int;

	function getUint32BE(byteOffset: Int): Int;

	function getFloat32BE(byteOffset: Int): FastFloat;

	function getFloat64BE(byteOffset: Int): Float;

	function setInt16BE(byteOffset: Int, value: Int): Void;

	function setUint16BE(byteOffset: Int, value: Int): Void;

	function setInt32BE(byteOffset: Int, value: Int): Void;

	function setUint32BE(byteOffset: Int, value: Int): Void;

	function setFloat32BE(byteOffset: Int, value: FastFloat): Void;

	function setFloat64BE(byteOffset: Int, value: Float): Void;

	function subarray(start: Int, ?end: Int): ByteArray;
}
