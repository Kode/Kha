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
		return cast this.self[this.byteArrayOffset + byteOffset];
	}

	public inline function getUint8(byteOffset: Int): Int {
		return untyped __cpp__("*(uint8_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
	}

	public inline function getInt16(byteOffset: Int): Int {
		return untyped __cpp__("*(int16_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
	}

	public inline function getUint16(byteOffset: Int): Int {
		return untyped __cpp__("*(uint16_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
	}

	public inline function getInt32(byteOffset: Int): Int {
		return untyped __cpp__("*(int32_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
	}

	public inline function getUint32(byteOffset: Int): Int {
		return untyped __cpp__("*(uint32_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
	}

	public inline function getFloat32(byteOffset: Int): FastFloat {
		return untyped __cpp__("*(float *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
	}

	public inline function getFloat64(byteOffset: Int): Float {
		return untyped __cpp__("*(double *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
	}

	public inline function setInt8(byteOffset: Int, value: Int): Void {
		return untyped __cpp__("*((int8_t *)&{0}.data[{1} + {2}]) = {3}", this.self, this.byteArrayOffset, byteOffset, value);
	}

	public inline function setUint8(byteOffset: Int, value: Int): Void {
		return untyped __cpp__("*((uint8_t *)&{0}.data[{1} + {2}]) = {3}", this.self, this.byteArrayOffset, byteOffset, value);
	}

	public inline function setInt16(byteOffset: Int, value: Int): Void {
		return untyped __cpp__("*((int16_t *)&{0}.data[{1} + {2}]) = {3}", this.self, this.byteArrayOffset, byteOffset, value);
	}

	public inline function setUint16(byteOffset: Int, value: Int): Void {
		return untyped __cpp__("*((uint16_t *)&{0}.data[{1} + {2}]) = {3}", this.self, this.byteArrayOffset, byteOffset, value);
	}

	public inline function setInt32(byteOffset: Int, value: Int): Void {
		return untyped __cpp__("*((int32_t *)&{0}.data[{1} + {2}]) = {3}", this.self, this.byteArrayOffset, byteOffset, value);
	}

	public inline function setUint32(byteOffset: Int, value: Int): Void {
		return untyped __cpp__("*((uint32_t *)&{0}.data[{1} + {2}]) = {3}", this.self, this.byteArrayOffset, byteOffset, value);
	}

	public inline function setFloat32(byteOffset: Int, value: FastFloat): Void {
		return untyped __cpp__("*((float *)&{0}.data[{1} + {2}]) = {3}", this.self, this.byteArrayOffset, byteOffset, value);
	}

	public inline function setFloat64(byteOffset: Int, value: Float): Void {
		return untyped __cpp__("*((double *)&{0}.data[{1} + {2}]) = {3}", this.self, this.byteArrayOffset, byteOffset, value);
	}

	public inline function getInt16LE(byteOffset: Int): Int {
		#if !sys_bigendian
		return untyped __cpp__("*(int16_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		return untyped __cpp__("({0}.data[{1} + {2} + 0] << 0) | ({0}.data[{1} + {2} + 1] << 8)", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function getUint16LE(byteOffset: Int): Int {
		#if !sys_bigendian
		return untyped __cpp__("*(uint16_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		return untyped __cpp__("({0}.data[{1} + {2} + 0] << 0) | ({0}.data[{1} + {2} + 1] << 8)", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function getInt32LE(byteOffset: Int): Int {
		#if !sys_bigendian
		return untyped __cpp__("*(int32_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		return
			untyped __cpp__("({0}.data[{1} + {2} + 0] << 0) | ({0}.data[{1} + {2} + 1] << 8) | ({0}.data[{1} + {2} + 2] << 16) | ({0}.data[{1} + {2} + 3] << 24)",
				this.self,
			this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function getUint32LE(byteOffset: Int): Int {
		#if !sys_bigendian
		return untyped __cpp__("*(uint32_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		return
			untyped __cpp__("({0}.data[{1} + {2} + 0] << 0) | ({0}.data[{1} + {2} + 1] << 8) | ({0}.data[{1} + {2} + 2] << 16) | ({0}.data[{1} + {2} + 3] << 24)",
				this.self,
			this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function getFloat32LE(byteOffset: Int): FastFloat {
		#if !sys_bigendian
		return untyped __cpp__("*(float *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		untyped __cpp__("int32_t i = ({0}.data[{1} + {2} + 0] << 0) | ({0}.data[{1} + {2} + 1] << 8) | ({0}.data[{1} + {2} + 2] << 16) | ({0}.data[{1} + {2} + 3] << 24)",
			this.self, this.byteArrayOffset, byteOffset);
		return untyped __cpp__("*(float *)&i");
		#end
	}

	public inline function getFloat64LE(byteOffset: Int): Float {
		#if !sys_bigendian
		return untyped __cpp__("*(double *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		untyped __cpp__("int64_t i = ((int64_t){0}.data[{1} + {2} + 0] << 0) | ((int64_t){0}.data[{1} + {2} + 1] << 8) | ((int64_t){0}.data[{1} + {2} + 2] << 16) | ((int64_t){0}.data[{1} + {2} + 3] << 24) | ((int64_t){0}.data[{1} + {2} + 4] << 32) | ((int64_t){0}.data[{1} + {2} + 5] << 40) | ((int64_t){0}.data[{1} + {2} + 6] << 48) | ((int64_t){0}.data[{1} + {2} + 7] << 56)",
			this.self, this.byteArrayOffset, byteOffset);
		return untyped __cpp__("*(double *)&i");
		#end
	}

	public inline function setInt16LE(byteOffset: Int, value: Int): Void {
		#if !sys_bigendian
		untyped __cpp__("*(int16_t *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("int16_t levalue = data[0] << 8 | data[1] << 0");
		untyped __cpp__("*(int16_t *)&{0}.data[{1} + {2}] = levalue", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setUint16LE(byteOffset: Int, value: Int): Void {
		#if !sys_bigendian
		untyped __cpp__("*(uint16_t *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("uint16_t levalue = data[0] << 8 | data[1] << 0");
		untyped __cpp__("*(uint16_t *)&{0}.data[{1} + {2}] = levalue", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setInt32LE(byteOffset: Int, value: Int): Void {
		#if !sys_bigendian
		untyped __cpp__("*(int32_t *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("int32_t levalue = data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0");
		untyped __cpp__("*(int32_t *)&{0}.data[{1} + {2}] = levalue", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setUint32LE(byteOffset: Int, value: Int): Void {
		#if !sys_bigendian
		untyped __cpp__("*(uint32_t *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("uint32_t levalue = data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0");
		untyped __cpp__("*(uint32_t *)&{0}.data[{1} + {2}] = levalue", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setFloat32LE(byteOffset: Int, value: FastFloat): Void {
		#if !sys_bigendian
		untyped __cpp__("*(float *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("int32_t levalue = data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0");
		untyped __cpp__("float lefloat = *(float*)&levalue");
		untyped __cpp__("*(float *)&{0}.data[{1} + {2}] = lefloat", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setFloat64LE(byteOffset: Int, value: Float): Void {
		#if !sys_bigendian
		untyped __cpp__("*(double *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("int64_t levalue = (int64_t)data[0] << 56 | (int64_t)data[1] << 48 | (int64_t)data[2] << 40 | (int64_t)data[3] << 32 | (int64_t)data[4] << 24 | (int64_t)data[5] << 16 | (int64_t)data[6] << 8 | (int64_t)data[7] << 0");
		untyped __cpp__("double lefloat = *(double*)&levalue");
		untyped __cpp__("*(double *)&{0}.data[{1} + {2}] = lefloat", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function getInt16BE(byteOffset: Int): Int {
		#if sys_bigendian
		return untyped __cpp__("*(int16_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		untyped __cpp__("int i = ({0}.data[{1} + {2} + 1] << 0) | ({0}.data[{1} + {2} + 0] << 8)", this.self, this.byteArrayOffset, byteOffset);
		return untyped __cpp__("*(float *)&i;");
		#end
	}

	public inline function getUint16BE(byteOffset: Int): Int {
		#if sys_bigendian
		return untyped __cpp__("*(uint16_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		untyped __cpp__("int i = ({0}.data[{1} + {2} + 1] << 0) | ({0}.data[{1} + {2} + 0] << 8)", this.self, this.byteArrayOffset, byteOffset);
		return untyped __cpp__("*(float *)&i;");
		#end
	}

	public inline function getInt32BE(byteOffset: Int): Int {
		#if sys_bigendian
		return untyped __cpp__("*(int32_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		return
			untyped __cpp__("({0}.data[{1} + {2} + 3] << 0) | ({0}.data[{1} + {2} + 2] << 8) | ({0}.data[{1} + {2} + 1] << 16) | ({0}.data[{1} + {2} + 0] << 24)",
				this.self,
			this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function getUint32BE(byteOffset: Int): Int {
		#if sys_bigendian
		return untyped __cpp__("*(uint32_t *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		return
			untyped __cpp__("({0}.data[{1} + {2} + 3] << 0) | ({0}.data[{1} + {2} + 2] << 8) | ({0}.data[{1} + {2} + 1] << 16) | ({0}.data[{1} + {2} + 0] << 24)",
				this.self,
			this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function getFloat32BE(byteOffset: Int): FastFloat {
		#if sys_bigendian
		return untyped __cpp__("*(float *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		untyped __cpp__("int32_t i = ({0}.data[{1} + {2} + 3] << 0) | ({0}.data[{1} + {2} + 2] << 8) | ({0}.data[{1} + {2} + 1] << 16) | ({0}.data[{1} + {2} + 0] << 24)",
			this.self, this.byteArrayOffset, byteOffset);
		return untyped __cpp__("*(float *)&i;");
		#end
	}

	public inline function getFloat64BE(byteOffset: Int): Float {
		#if sys_bigendian
		return untyped __cpp__("*(double *)&{0}.data[{1} + {2}]", this.self, this.byteArrayOffset, byteOffset);
		#else
		untyped __cpp__("int64_t i = ((int64_t){0}.data[{1} + {2} + 7] << 0) | ((int64_t){0}.data[{1} + {2} + 6] << 8) | ((int64_t){0}.data[{1} + {2} + 5] << 16) | ((int64_t){0}.data[{1} + {2} + 4] << 24) | ((int64_t){0}.data[{1} + {2} + 3] << 32) | ((int64_t){0}.data[{1} + {2} + 2] << 40) | ((int64_t){0}.data[{1} + {2} + 1] << 48) | ((int64_t){0}.data[{1} + {2} + 0] << 56)",
			this.self, this.byteArrayOffset, byteOffset);
		return untyped __cpp__("*(double *)&i;");
		#end
	}

	public inline function setInt16BE(byteOffset: Int, value: Int): Void {
		#if sys_bigendian
		untyped __cpp__("*(int16_t *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("int16_t levalue = data[0] << 8 | data[1] << 0");
		untyped __cpp__("*(int16_t *)&{0}.data[{1} + {2}] = levalue", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setUint16BE(byteOffset: Int, value: Int): Void {
		#if sys_bigendian
		untyped __cpp__("*(uint16_t *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("uint16_t levalue = data[0] << 8 | data[1] << 0");
		untyped __cpp__("*(uint16_t *)&{0}.data[{1} + {2}] = levalue", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setInt32BE(byteOffset: Int, value: Int): Void {
		#if sys_bigendian
		untyped __cpp__("*(int32_t *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("int32_t levalue = data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0");
		untyped __cpp__("*(int32_t *)&{0}.data[{1} + {2}] = levalue", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setUint32BE(byteOffset: Int, value: Int): Void {
		#if sys_bigendian
		untyped __cpp__("*(uint32_t *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("uint32_t levalue = data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0");
		untyped __cpp__("*(uint32_t *)&{0}.data[{1} + {2}] = levalue", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setFloat32BE(byteOffset: Int, value: FastFloat): Void {
		#if sys_bigendian
		untyped __cpp__("*(float *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("int32_t levalue = data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0");
		untyped __cpp__("float lefloat = *(float*)&levalue");
		untyped __cpp__("*(float *)&{0}.data[{1} + {2}] = lefloat", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public inline function setFloat64BE(byteOffset: Int, value: Float): Void {
		#if sys_bigendian
		untyped __cpp__("*(double *)&{0}.data[{1} + {2}] = {3}", this.self, this.byteArrayOffset, byteOffset, value);
		#else
		untyped __cpp__("int8_t * data = (int8_t *)&{0}", value);
		untyped __cpp__("int64_t levalue = (int64_t)data[0] << 56 | (int64_t)data[1] << 48 | (int64_t)data[2] << 40 | (int64_t)data[3] << 32 | (int64_t)data[4] << 24 | (int64_t)data[5] << 16 | (int64_t)data[6] << 8 | (int64_t)data[7] << 0");
		untyped __cpp__("double lefloat = *(double*)&levalue");
		untyped __cpp__("*(double *)&{0}.data[{1} + {2}] = lefloat", this.self, this.byteArrayOffset, byteOffset);
		#end
	}

	public function subarray(start: Int, ?end: Int): ByteArray {
		var offset: Int = this.byteArrayOffset + start;
		var length: Int = end == null ? this.byteArrayLength - start : end - start;
		return new ByteArray(this.self, offset, length);
	}
}
