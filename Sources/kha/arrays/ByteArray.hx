package kha.arrays;

/**
 * Maps a byte array over a byte buffer, allowing for mixed-type access of its contents.
 * This type unifies with all typed array classes, and vice-versa.
 */
extern class ByteArray {
	/**
	 * Underlying byte buffer.
	 */
	var buffer(get, null): ByteBuffer;

	/**
	 * Length in bytes of the byte array.
	 */
	var byteLength(get, null): Int;

	/**
	 * Byte offset into the underlying byte buffer.
	 */
	var byteOffset(get, null): Int;

	/**
	 * Creates a new array over a byte buffer.
	 * @param buffer underlying byte buffer
	 * @param byteOffset offset of the first byte of the array into the byte buffer, defaults to 0
	 * @param byteLength amount of bytes to map, defaults to entire buffer 
	 */
	function new(buffer: ByteArray, ?byteOffset: Int, ?byteLength: Int): Void;

	/**
	 * Creates a new array from scratch.
	 * @param byteLength number of bytes to create
	 * @return ByteArray
	 */
	static function make(byteLength: Int): ByteArray;

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
