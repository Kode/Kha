package kha.arrays;

import java.nio.ByteOrder;

abstract ByteBuffer(java.nio.ByteBuffer) {
	public inline function new(size: Int) {
		this = java.nio.ByteBuffer.allocateDirect(size).order(ByteOrder.nativeOrder());
	}

	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.capacity();
	}

	@:arrayAccess
	public inline function set(index: Int, value: Int): Int {
		this.put(index, value);
		return value;
	}

	@:arrayAccess
	public inline function get(index: Int): Int {
		return cast this.get(index);
	}

	public inline function getShort(index: Int): Int {
		return cast this.order(ByteOrder.nativeOrder()).getShort(index);
	}

	public inline function getShortLE(index: Int): Int {
		return cast this.order(ByteOrder.LITTLE_ENDIAN).getShort(index);
	}

	public inline function getShortBE(index: Int): Int {
		return cast this.order(ByteOrder.BIG_ENDIAN).getShort(index);
	}

	public inline function getInt(index: Int): Int {
		return this.order(ByteOrder.nativeOrder()).getInt(index);
	}

	public inline function getIntLE(index: Int): Int {
		return this.order(ByteOrder.LITTLE_ENDIAN).getInt(index);
	}

	public inline function getIntBE(index: Int): Int {
		return this.order(ByteOrder.BIG_ENDIAN).getInt(index);
	}

	public inline function getFloat(index: Int): Float {
		return this.order(ByteOrder.nativeOrder()).getFloat(index);
	}

	public inline function getFloatLE(index: Int): Float {
		return this.order(ByteOrder.LITTLE_ENDIAN).getFloat(index);
	}

	public inline function getFloatBE(index: Int): Float {
		return this.order(ByteOrder.BIG_ENDIAN).getFloat(index);
	}

	public inline function getDouble(index: Int): Float {
		return this.order(ByteOrder.nativeOrder()).getDouble(index);
	}

	public inline function getDoubleLE(index: Int): Float {
		return this.order(ByteOrder.LITTLE_ENDIAN).getDouble(index);
	}

	public inline function getDoubleBE(index: Int): Float {
		return this.order(ByteOrder.BIG_ENDIAN).getDouble(index);
	}

	public inline function setShort(index: Int, value: Int): Void {
		this.order(ByteOrder.nativeOrder()).putShort(index, value);
	}

	public inline function setShortLE(index: Int, value: Int): Void {
		this.order(ByteOrder.LITTLE_ENDIAN).putShort(index, value);
	}

	public inline function setShortBE(index: Int, value: Int): Void {
		this.order(ByteOrder.BIG_ENDIAN).putShort(index, value);
	}

	public inline function setInt(index: Int, value: Int): Void {
		this.order(ByteOrder.nativeOrder()).putInt(index, value);
	}

	public inline function setIntLE(index: Int, value: Int): Void {
		this.order(ByteOrder.LITTLE_ENDIAN).putInt(index, value);
	}

	public inline function setIntBE(index: Int, value: Int): Void {
		this.order(ByteOrder.BIG_ENDIAN).putInt(index, value);
	}

	public inline function setFloat(index: Int, value: Float): Void {
		this.order(ByteOrder.nativeOrder()).putFloat(index, value);
	}

	public inline function setFloatLE(index: Int, value: Float): Void {
		this.order(ByteOrder.LITTLE_ENDIAN).putFloat(index, value);
	}

	public inline function setFloatBE(index: Int, value: Float): Void {
		this.order(ByteOrder.BIG_ENDIAN).putFloat(index, value);
	}

	public inline function setDouble(index: Int, value: Float): Void {
		this.order(ByteOrder.nativeOrder()).putDouble(index, value);
	}

	public inline function setDoubleLE(index: Int, value: Float): Void {
		this.order(ByteOrder.LITTLE_ENDIAN).putDouble(index, value);
	}

	public inline function setDoubleBE(index: Int, value: Float): Void {
		this.order(ByteOrder.BIG_ENDIAN).putDouble(index, value);
	}
}
