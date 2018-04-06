package kha.arrays;

import kha.FastFloat;

abstract Float32Array(haxe.io.Bytes) {
	
	public inline function new(elements: Int) {
		this = haxe.io.Bytes.alloc(elements * 4);
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return Std.int(this.length / 4);
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		this.setFloat(index * 4, value);
		return value;
	}
	
	public inline function get(index: Int): FastFloat {
		return this.getFloat(index * 4);
	}

	@:arrayAccess
	public inline function arrayRead(index: Int): FastFloat {
		return get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: FastFloat): FastFloat {
		return set(index, value);
	}

	public function getData():haxe.io.BytesData {
		return this.getData();
	}
}
