package kha.arrays;

import js.lib.DataView;
import kha.FastFloat;

@:forward
abstract ByteArray(DataView) to DataView {
	static final LITTLE_ENDIAN: Bool = js.Syntax.code("new Uint8Array(new Uint32Array([0x12345678]).buffer)[0] === 0x78");

	public var buffer(get, never): ByteBuffer;

	function get_buffer(): ByteBuffer {
		return cast this.buffer;
	}

	public function new(buffer: ByteBuffer, ?byteOffset: Int, ?byteLength: Int) {
		this = new DataView(buffer, byteOffset, byteLength);
	}

	static public function make(byteLength: Int): ByteArray {
		return new ByteArray(new ByteBuffer(byteLength));
	}

	public function getInt8(byteOffset: Int): Int {
		return this.getInt8(byteOffset);
	}

	public function getUint8(byteOffset: Int): Int {
		return this.getUint8(byteOffset);
	}

	public function getInt16(byteOffset: Int): Int {
		return this.getInt16(byteOffset, LITTLE_ENDIAN);
	}

	public function getUint16(byteOffset: Int): Int {
		return this.getUint16(byteOffset, LITTLE_ENDIAN);
	}

	public function getInt32(byteOffset: Int): Int {
		return this.getInt32(byteOffset, LITTLE_ENDIAN);
	}

	public function getUint32(byteOffset: Int): Int {
		return this.getUint32(byteOffset, LITTLE_ENDIAN);
	}

	public function getFloat32(byteOffset: Int): FastFloat {
		return this.getFloat32(byteOffset, LITTLE_ENDIAN);
	}

	public function getFloat64(byteOffset: Int): Float {
		return this.getFloat64(byteOffset, LITTLE_ENDIAN);
	}

	public function setInt8(byteOffset: Int, value: Int): Void {
		this.setInt8(byteOffset, value);
	}

	public function setUint8(byteOffset: Int, value: Int): Void {
		this.setUint8(byteOffset, value);
	}

	public function setInt16(byteOffset: Int, value: Int): Void {
		this.setInt16(byteOffset, value, LITTLE_ENDIAN);
	}

	public function setUint16(byteOffset: Int, value: Int): Void {
		this.setUint16(byteOffset, value, LITTLE_ENDIAN);
	}

	public function setInt32(byteOffset: Int, value: Int): Void {
		this.setInt32(byteOffset, value, LITTLE_ENDIAN);
	}

	public function setUint32(byteOffset: Int, value: Int): Void {
		this.setUint32(byteOffset, value, LITTLE_ENDIAN);
	}

	public function setFloat32(byteOffset: Int, value: FastFloat): Void {
		this.setFloat32(byteOffset, value, LITTLE_ENDIAN);
	}

	public function setFloat64(byteOffset: Int, value: Float): Void {
		this.setFloat64(byteOffset, value, LITTLE_ENDIAN);
	}

	public function getInt16LE(byteOffset: Int): Int {
		return this.getInt16(byteOffset, true);
	}

	public function getUint16LE(byteOffset: Int): Int {
		return this.getUint16(byteOffset, true);
	}

	public function getInt32LE(byteOffset: Int): Int {
		return this.getInt32(byteOffset, true);
	}

	public function getUint32LE(byteOffset: Int): Int {
		return this.getUint32(byteOffset, true);
	}

	public function getFloat32LE(byteOffset: Int): FastFloat {
		return this.getFloat32(byteOffset, true);
	}

	public function getFloat64LE(byteOffset: Int): Float {
		return this.getFloat64(byteOffset, true);
	}

	public function setInt16LE(byteOffset: Int, value: Int): Void {
		this.setInt16(byteOffset, value, true);
	}

	public function setUint16LE(byteOffset: Int, value: Int): Void {
		this.setUint16(byteOffset, value, true);
	}

	public function setInt32LE(byteOffset: Int, value: Int): Void {
		this.setInt32(byteOffset, value, true);
	}

	public function setUint32LE(byteOffset: Int, value: Int): Void {
		this.setUint32(byteOffset, value, true);
	}

	public function setFloat32LE(byteOffset: Int, value: FastFloat): Void {
		this.setFloat32(byteOffset, value, true);
	}

	public function setFloat64LE(byteOffset: Int, value: Float): Void {
		this.setFloat64(byteOffset, value, true);
	}

	public function getInt16BE(byteOffset: Int): Int {
		return this.getInt16(byteOffset);
	}

	public function getUint16BE(byteOffset: Int): Int {
		return this.getUint16(byteOffset);
	}

	public function getInt32BE(byteOffset: Int): Int {
		return this.getInt32(byteOffset);
	}

	public function getUint32BE(byteOffset: Int): Int {
		return this.getUint32(byteOffset);
	}

	public function getFloat32BE(byteOffset: Int): FastFloat {
		return this.getFloat32(byteOffset);
	}

	public function getFloat64BE(byteOffset: Int): Float {
		return this.getFloat64(byteOffset);
	}

	public function setInt16BE(byteOffset: Int, value: Int): Void {
		this.setInt16(byteOffset, value);
	}

	public function setUint16BE(byteOffset: Int, value: Int): Void {
		this.setUint16(byteOffset, value);
	}

	public function setInt32BE(byteOffset: Int, value: Int): Void {
		this.setInt32(byteOffset, value);
	}

	public function setUint32BE(byteOffset: Int, value: Int): Void {
		this.setUint32(byteOffset, value);
	}

	public function setFloat32BE(byteOffset: Int, value: FastFloat): Void {
		this.setFloat32(byteOffset, value);
	}

	public function setFloat64BE(byteOffset: Int, value: Float): Void {
		this.setFloat64(byteOffset, value);
	}

	public function subarray(start: Int, ?end: Int): ByteArray {
		return new ByteArray(buffer, start, end != null ? end - start : null);
	}
}
