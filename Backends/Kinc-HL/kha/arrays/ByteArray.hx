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
		var buffer = ByteBuffer.create(byteLength);
		return new ByteArray(buffer, 0, byteLength);
	}

	public inline function free() {
		this.self.free();
	}

	public inline function getData(): Pointer {
		return this.self;
	}

	// Get

	public inline function getInt8(byteOffset: Int): Int {
		return kore_bytearray_getint8(this.self, this.byteArrayOffset + byteOffset);
	}

	public inline function getUint8(byteOffset: Int): Int {
		return kore_bytearray_getuint8(this.self, this.byteArrayOffset + byteOffset);
	}

	public inline function getInt16(byteOffset: Int): Int {
		return kore_bytearray_getint16(this.self, this.byteArrayOffset + byteOffset);
	}

	public inline function getUint16(byteOffset: Int): Int {
		return kore_bytearray_getuint16(this.self, this.byteArrayOffset + byteOffset);
	}

	public inline function getInt32(byteOffset: Int): Int {
		return kore_bytearray_getint32(this.self, this.byteArrayOffset + byteOffset);
	}

	public inline function getUint32(byteOffset: Int): Int {
		return kore_bytearray_getuint32(this.self, this.byteArrayOffset + byteOffset);
	}

	public inline function getFloat32(byteOffset: Int): FastFloat {
		return kore_bytearray_getfloat32(this.self, this.byteArrayOffset + byteOffset);
	}

	public inline function getFloat64(byteOffset: Int): Float {
		return kore_bytearray_getfloat64(this.self, this.byteArrayOffset + byteOffset);
	}

	// Set

	public inline function setInt8(byteOffset: Int, value: Int): Void {
		kore_bytearray_setint8(this.self, this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint8(byteOffset: Int, value: Int): Void {
		kore_bytearray_setuint8(this.self, this.byteArrayOffset + byteOffset, value);
	}

	public inline function setInt16(byteOffset: Int, value: Int): Void {
		kore_bytearray_setint16(this.self, this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint16(byteOffset: Int, value: Int): Void {
		kore_bytearray_setuint16(this.self, this.byteArrayOffset + byteOffset, value);
	}

	public inline function setInt32(byteOffset: Int, value: Int): Void {
		kore_bytearray_setint32(this.self, this.byteArrayOffset + byteOffset, value);
	}

	public inline function setUint32(byteOffset: Int, value: Int): Void {
		kore_bytearray_setuint32(this.self, this.byteArrayOffset + byteOffset, value);
	}

	public inline function setFloat32(byteOffset: Int, value: FastFloat): Void {
		kore_bytearray_setfloat32(this.self, this.byteArrayOffset + byteOffset, value);
	}

	public inline function setFloat64(byteOffset: Int, value: Float): Void {
		kore_bytearray_setfloat64(this.self, this.byteArrayOffset + byteOffset, value);
	}

	// Get (little endian)

	public inline function getInt16LE(byteOffset: Int): Int {
		#if !sys_bigendian
		return getInt16(byteOffset);
		#else
		return kore_bytearray_getint16_le(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getUint16LE(byteOffset: Int): Int {
		#if !sys_bigendian
		return getUint16(byteOffset);
		#else
		return kore_bytearray_getuint16_le(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getInt32LE(byteOffset: Int): Int {
		#if !sys_bigendian
		return getInt32(byteOffset);
		#else
		return kore_bytearray_getint32_le(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getUint32LE(byteOffset: Int): Int {
		#if !sys_bigendian
		return getUint32(byteOffset);
		#else
		return kore_bytearray_getuint32_le(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getFloat32LE(byteOffset: Int): FastFloat {
		#if !sys_bigendian
		return getFloat32(byteOffset);
		#else
		return kore_bytearray_getfloat32_le(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getFloat64LE(byteOffset: Int): Float {
		#if !sys_bigendian
		return getFloat64(byteOffset);
		#else
		return kore_bytearray_getfloat64_le(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	// Set (little endian)

	public inline function setInt16LE(byteOffset: Int, value: Int): Void {
		#if !sys_bigendian
		setInt16(byteOffset, value);
		#else
		kore_bytearray_setint16_le(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setUint16LE(byteOffset: Int, value: Int): Void {
		#if !sys_bigendian
		setUint16(byteOffset, value);
		#else
		kore_bytearray_setuint16_le(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setInt32LE(byteOffset: Int, value: Int): Void {
		#if !sys_bigendian
		setInt32(byteOffset, value);
		#else
		kore_bytearray_setint32_le(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setUint32LE(byteOffset: Int, value: Int): Void {
		#if !sys_bigendian
		setUint32(byteOffset, value);
		#else
		kore_bytearray_setuint32_le(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setFloat32LE(byteOffset: Int, value: FastFloat): Void {
		#if !sys_bigendian
		setFloat32(byteOffset, value);
		#else
		kore_bytearray_setfloat32_le(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setFloat64LE(byteOffset: Int, value: Float): Void {
		#if !sys_bigendian
		setFloat64(byteOffset, value);
		#else
		kore_bytearray_setfloat64_le(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	// Get (big endian)

	public inline function getInt16BE(byteOffset: Int): Int {
		#if sys_bigendian
		return getInt16(byteOffset);
		#else
		return kore_bytearray_getint16_be(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getUint16BE(byteOffset: Int): Int {
		#if sys_bigendian
		return getUint16(byteOffset);
		#else
		return kore_bytearray_getuint16_be(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getInt32BE(byteOffset: Int): Int {
		#if sys_bigendian
		return getInt32(byteOffset);
		#else
		return kore_bytearray_getint32_be(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getUint32BE(byteOffset: Int): Int {
		#if sys_bigendian
		return getUint32(byteOffset);
		#else
		return kore_bytearray_getuint32_be(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getFloat32BE(byteOffset: Int): FastFloat {
		#if sys_bigendian
		return getFloat32(byteOffset);
		#else
		return kore_bytearray_getfloat32_be(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	public inline function getFloat64BE(byteOffset: Int): Float {
		#if sys_bigendian
		return getFloat64(byteOffset);
		#else
		return kore_bytearray_getfloat64_be(this.self, this.byteArrayOffset + byteOffset);
		#end
	}

	// Set (big endian)

	public inline function setInt16BE(byteOffset: Int, value: Int): Void {
		#if sys_bigendian
		setInt16(byteOffset, value);
		#else
		kore_bytearray_setint16_be(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setUint16BE(byteOffset: Int, value: Int): Void {
		#if sys_bigendian
		setUint16(byteOffset, value);
		#else
		kore_bytearray_setuint16_be(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setInt32BE(byteOffset: Int, value: Int): Void {
		#if sys_bigendian
		setInt32(byteOffset, value);
		#else
		kore_bytearray_setint32_be(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setUint32BE(byteOffset: Int, value: Int): Void {
		#if sys_bigendian
		setUint32(byteOffset, value);
		#else
		kore_bytearray_setuint32_be(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setFloat32BE(byteOffset: Int, value: FastFloat): Void {
		#if sys_bigendian
		setFloat32(byteOffset, value);
		#else
		kore_bytearray_setfloat32_be(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public inline function setFloat64BE(byteOffset: Int, value: Float): Void {
		#if sys_bigendian
		setFloat64(byteOffset, value);
		#else
		kore_bytearray_setfloat64_be(this.self, this.byteArrayOffset + byteOffset, value);
		#end
	}

	public function subarray(start: Int, ?end: Int): ByteArray {
		var offset: Int = this.byteArrayOffset + start;
		var length: Int = end == null ? this.byteArrayLength - start : end - start;
		return new ByteArray(this.self, offset, length);
	}

	@:hlNative("std", "kore_bytearray_getint8") static function kore_bytearray_getint8(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getuint8") static function kore_bytearray_getuint8(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getint16") static function kore_bytearray_getint16(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getuint16") static function kore_bytearray_getuint16(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getint32") static function kore_bytearray_getint32(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getuint32") static function kore_bytearray_getuint32(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getfloat32") static function kore_bytearray_getfloat32(bytearray: Pointer, byteOffset: Int): FastFloat { return 0; }
	@:hlNative("std", "kore_bytearray_getfloat64") static function kore_bytearray_getfloat64(bytearray: Pointer, byteOffset: Int): Float { return 0; }

	@:hlNative("std", "kore_bytearray_setint8") static function kore_bytearray_setint8(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setuint8") static function kore_bytearray_setuint8(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setint16") static function kore_bytearray_setint16(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setuint16") static function kore_bytearray_setuint16(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setint32") static function kore_bytearray_setint32(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setuint32") static function kore_bytearray_setuint32(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setfloat32") static function kore_bytearray_setfloat32(bytearray: Pointer, byteOffset: Int, value: FastFloat) {}
	@:hlNative("std", "kore_bytearray_setfloat64") static function kore_bytearray_setfloat64(bytearray: Pointer, byteOffset: Int, value: Float) {}

	// Variants for little endian on big endian system

	@:hlNative("std", "kore_bytearray_getint16_le") static function kore_bytearray_getint16_le(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getuint16_le") static function kore_bytearray_getuint16_le(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getint32_le") static function kore_bytearray_getint32_le(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getuint32_le") static function kore_bytearray_getuint32_le(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getfloat32_le") static function kore_bytearray_getfloat32_le(bytearray: Pointer, byteOffset: Int): FastFloat { return 0; }
	@:hlNative("std", "kore_bytearray_getfloat64_le") static function kore_bytearray_getfloat64_le(bytearray: Pointer, byteOffset: Int): Float { return 0; }

	@:hlNative("std", "kore_bytearray_setint16_le") static function kore_bytearray_setint16_le(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setuint16_le") static function kore_bytearray_setuint16_le(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setint32_le") static function kore_bytearray_setint32_le(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setuint32_le") static function kore_bytearray_setuint32_le(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setfloat32_le") static function kore_bytearray_setfloat32_le(bytearray: Pointer, byteOffset: Int, value: FastFloat) {}
	@:hlNative("std", "kore_bytearray_setfloat64_le") static function kore_bytearray_setfloat64_le(bytearray: Pointer, byteOffset: Int, value: Float) {}

	// Variants for big endian on little endian system

	@:hlNative("std", "kore_bytearray_getint16_be") static function kore_bytearray_getint16_be(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getuint16_be") static function kore_bytearray_getuint16_be(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getint32_be") static function kore_bytearray_getint32_be(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getuint32_be") static function kore_bytearray_getuint32_be(bytearray: Pointer, byteOffset: Int): Int { return 0; }
	@:hlNative("std", "kore_bytearray_getfloat32_be") static function kore_bytearray_getfloat32_be(bytearray: Pointer, byteOffset: Int): FastFloat { return 0; }
	@:hlNative("std", "kore_bytearray_getfloat64_be") static function kore_bytearray_getfloat64_be(bytearray: Pointer, byteOffset: Int): Float { return 0; }

	@:hlNative("std", "kore_bytearray_setint16_be") static function kore_bytearray_setint16_be(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setuint16_be") static function kore_bytearray_setuint16_be(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setint32_be") static function kore_bytearray_setint32_be(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setuint32_be") static function kore_bytearray_setuint32_be(bytearray: Pointer, byteOffset: Int, value: Int) {}
	@:hlNative("std", "kore_bytearray_setfloat32_be") static function kore_bytearray_setfloat32_be(bytearray: Pointer, byteOffset: Int, value: FastFloat) {}
	@:hlNative("std", "kore_bytearray_setfloat64_be") static function kore_bytearray_setfloat64_be(bytearray: Pointer, byteOffset: Int, value: Float) {}
}
