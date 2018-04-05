package kha.arrays;

import kha.FastFloat;

class Float32Array {
	public var _data: haxe.io.Bytes;
	
	public inline function new(elements: Int) {
		_data = haxe.io.Bytes.alloc(elements * 4);
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return Std.int(_data.length / 4);
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		_data.setFloat(index * 4, value);
		return value;
	}
	
	public inline function get(index: Int): FastFloat {
		return _data.getFloat(index * 4);
	}
}
