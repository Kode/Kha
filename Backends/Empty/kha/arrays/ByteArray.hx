package kha.arrays;

import kha.FastFloat;

class ByteArray {
	public var buffer(get, never): ByteBuffer;

	inline function get_buffer(): ByteBuffer {
		return cast this.buffer;
	}

	public function new(buffer: ByteBuffer, ?byteOffset: Int, ?byteLength: Int) {
		
	}

	static public function make(byteLength: Int): ByteArray {
		return null;
	}

	public inline function getInt8(byteOffset: Int): Int {
		return 0;
	}

	public inline function getUint8(byteOffset: Int): Int {
		return 0;
	}

	public inline function getInt16(byteOffset: Int): Int {
		return 0;
	}

	public inline function getUint16(byteOffset: Int): Int {
		return 0;
	}

	public inline function getInt32(byteOffset: Int): Int {
		return 0;
	}

	public inline function getUint32(byteOffset: Int): Int {
		return 0;
	}

	public inline function getFloat32(byteOffset: Int): FastFloat {
		return 0;
	}

	public inline function getFloat64(byteOffset: Int): Float {
		return 0;
	}

	public inline function setInt8(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setUint8(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setInt16(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setUint16(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setInt32(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setUint32(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setFloat32(byteOffset: Int, value: FastFloat): Void {
		
	}

	public inline function setFloat64(byteOffset: Int, value: Float): Void {
		
	}

	public inline function getInt16LE(byteOffset: Int): Int {
		return 0;
	}

	public inline function getUint16LE(byteOffset: Int): Int {
		return 0;
	}

	public inline function getInt32LE(byteOffset: Int): Int {
		return 0;
	}

	public inline function getUint32LE(byteOffset: Int): Int {
		return 0;
	}

	public inline function getFloat32LE(byteOffset: Int): FastFloat {
		return 0;
	}

	public inline function getFloat64LE(byteOffset: Int): Float {
		return 0;
	}

	public inline function setInt16LE(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setUint16LE(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setInt32LE(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setUint32LE(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setFloat32LE(byteOffset: Int, value: FastFloat): Void {
		
	}

	public inline function setFloat64LE(byteOffset: Int, value: Float): Void {
		
	}

	public inline function getInt16BE(byteOffset: Int): Int {
		return 0;
	}

	public inline function getUint16BE(byteOffset: Int): Int {
		return 0;
	}

	public inline function getInt32BE(byteOffset: Int): Int {
		return 0;
	}

	public inline function getUint32BE(byteOffset: Int): Int {
		return 0;
	}

	public inline function getFloat32BE(byteOffset: Int): FastFloat {
		return 0;
	}

	public inline function getFloat64BE(byteOffset: Int): Float {
		return 0;
	}

	public inline function setInt16BE(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setUint16BE(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setInt32BE(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setUint32BE(byteOffset: Int, value: Int): Void {
		
	}

	public inline function setFloat32BE(byteOffset: Int, value: FastFloat): Void {
		
	}

	public inline function setFloat64BE(byteOffset: Int, value: Float): Void {
		
	}

	public inline function subarray(start: Int, ?end: Int): ByteArray {
		return new ByteArray(buffer, start, end != null ? end - start : null);
	}
}
