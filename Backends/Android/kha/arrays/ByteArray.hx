package kha.arrays;

class ByteArrayPrivate {
	public var self: ByteBuffer;
	public var byteArrayOffset: Int;
	public var byteArrayLength: Int;

	public inline function new(offset: Int, length: Int) {
		this.byteArrayOffset = offset;
		this.byteArrayLength = length;
	}
}

abstract ByteArray(ByteArrayPrivate) {
	public var buffer(get, never): ByteBuffer;

	inline function get_buffer(): ByteBuffer {
		return this.self;
	}

	public var byteLength(get, never): Int;

	inline function get_byteLength(): Int {
		return this.byteArrayLength;
	}

	public var byteOffset(get, never): Int;

	inline function get_byteOffset(): Int {
		return this.byteArrayOffset;
	}

	public inline function new(buffer: ByteBuffer, byteOffset: Int, byteLength: Int): Void {
		this = new ByteArrayPrivate(byteOffset, byteLength);
		this.self = buffer;
	}

	public static inline function make(byteLength: Int): ByteArray {
		var buffer = new ByteBuffer(byteLength);
		return new ByteArray(buffer, 0, byteLength);
	}

	public inline function data(count: Int): java.nio.ByteBuffer {
		return java.nio.ByteBuffer.wrap(cast this.self, 0, count);
	}

	public inline function getInt8(byteOffset: Int): Int {
		return this.self[this.byteArrayOffset + byteOffset];
	}

	public inline function getUint8(byteOffset: Int): Int {
		return getInt8(byteOffset);
	}

	public inline function getInt16(byteOffset: Int): Int {
		return this.self.getShort(this.byteArrayOffset + byteOffset);
	}

	public inline function getUint16(byteOffset: Int): Int {
		return getInt16(byteOffset);
	}

	public inline function getInt32(byteOffset: Int): Int {
		return this.self.getInt(this.byteArrayOffset + byteOffset);
	}

	public inline function getUint32(byteOffset: Int): Int {
		return getInt32(byteOffset);
	}

	public inline function getFloat32(byteOffset: Int): FastFloat {
		return this.self.getFloat(this.byteArrayOffset + byteOffset);
	}

	public inline function getFloat64(byteOffset: Int): Float {
		return this.self.getDouble(this.byteArrayOffset + byteOffset);
	}

	public inline function setInt8(byteOffset: Int, value: Int): Void {
		this.self.set(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint8(byteOffset: Int, value: Int): Void {
		setInt8(byteOffset, value);
	}

	public inline function setInt16(byteOffset: Int, value: Int): Void {
		this.self.setShort(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint16(byteOffset: Int, value: Int): Void {
		setInt16(byteOffset, value);
	}

	public inline function setInt32(byteOffset: Int, value: Int): Void {
		this.self.setInt(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint32(byteOffset: Int, value: Int): Void {
		setInt32(byteOffset, value);
	}

	public inline function setFloat32(byteOffset: Int, value: FastFloat): Void {
		this.self.setFloat(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setFloat64(byteOffset: Int, value: Float): Void {
		this.self.setDouble(this.byteArrayOffset + byteOffset, value);
	}

	public inline function getInt16LE(byteOffset: Int): Int {
		return this.self.getShortLE(this.byteArrayOffset + byteOffset);
	}

	public inline function getUint16LE(byteOffset: Int): Int {
		return getInt16LE(byteOffset);
	}

	public inline function getInt32LE(byteOffset: Int): Int {
		return this.self.getIntLE(this.byteArrayOffset + byteOffset);
	}

	public inline function getUint32LE(byteOffset: Int): Int {
		return getInt32LE(byteOffset);
	}

	public inline function getFloat32LE(byteOffset: Int): FastFloat {
		return this.self.getFloatLE(this.byteArrayOffset + byteOffset);
	}

	public inline function getFloat64LE(byteOffset: Int): Float {
		return this.self.getDoubleLE(this.byteArrayOffset + byteOffset);
	}

	public inline function setInt16LE(byteOffset: Int, value: Int): Void {
		this.self.setShortLE(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint16LE(byteOffset: Int, value: Int): Void {
		setInt16LE(byteOffset, value);
	}

	public inline function setInt32LE(byteOffset: Int, value: Int): Void {
		this.self.setIntLE(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint32LE(byteOffset: Int, value: Int): Void {
		setInt32LE(byteOffset, value);
	}

	public inline function setFloat32LE(byteOffset: Int, value: FastFloat): Void {
		this.self.setFloatLE(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setFloat64LE(byteOffset: Int, value: Float): Void {
		this.self.setDoubleLE(this.byteArrayOffset + byteOffset, value);
	}

	public inline function getInt16BE(byteOffset: Int): Int {
		return this.self.getShortBE(this.byteArrayOffset + byteOffset);
	}

	public inline function getUint16BE(byteOffset: Int): Int {
		return getInt16BE(byteOffset);
	}

	public inline function getInt32BE(byteOffset: Int): Int {
		return this.self.getIntBE(this.byteArrayOffset + byteOffset);
	}

	public inline function getUint32BE(byteOffset: Int): Int {
		return getInt32BE(byteOffset);
	}

	public inline function getFloat32BE(byteOffset: Int): FastFloat {
		return this.self.getFloatBE(this.byteArrayOffset + byteOffset);
	}

	public inline function getFloat64BE(byteOffset: Int): Float {
		return this.self.getDoubleBE(this.byteArrayOffset + byteOffset);
	}

	public inline function setInt16BE(byteOffset: Int, value: Int): Void {
		this.self.setShortBE(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint16BE(byteOffset: Int, value: Int): Void {
		setInt16BE(byteOffset, value);
	}

	public inline function setInt32BE(byteOffset: Int, value: Int): Void {
		this.self.setIntBE(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint32BE(byteOffset: Int, value: Int): Void {
		setInt32BE(byteOffset, value);
	}

	public inline function setFloat32BE(byteOffset: Int, value: FastFloat): Void {
		this.self.setFloatBE(this.byteArrayOffset + byteOffset, value);
	}

	public inline function setFloat64BE(byteOffset: Int, value: Float): Void {
		this.self.setDoubleBE(this.byteArrayOffset + byteOffset, value);
	}

	public function subarray(start: Int, ?end: Int): ByteArray {
		var offset: Int = this.byteArrayOffset + start;
		var length: Int = end == null ? this.byteArrayLength - start : end - start;
		return new ByteArray(this.self, offset, length);
	}
}
