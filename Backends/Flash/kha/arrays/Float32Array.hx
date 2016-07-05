package kha.arrays;

import flash.utils.ByteArray;
import kha.FastFloat;

abstract Float32Array(ByteArray) {
	private static inline var elementSize = 4;
	
	public inline function new(elements: Int) {
		this = new ByteArray();
		this.endian = flash.utils.Endian.LITTLE_ENDIAN;
		this.length = elements * elementSize;
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length >> 2;
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		this.position = index * elementSize;
		this.writeFloat(value);
		return value;
	}
	
	public inline function get(index: Int): FastFloat {
		this.position = index * elementSize;
		return this.readFloat();
	}
	
	public inline function data(): ByteArray {
		return this;
	}
}
