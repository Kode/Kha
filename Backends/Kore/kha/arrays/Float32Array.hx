package kha.arrays;

import cpp.RawPointer;
import haxe.ds.Vector;
import kha.FastFloat;

@:unreflective
@:structAccess
@:include("cpp_float32array.h")
@:native("float32array")
extern class Float32ArrayData {
	@:native("float32array")
	public static function create(): Float32ArrayData;
	
	public var length(get, never): Int;

	@:native("length")
	function get_length(): Int {
		return 0;
	}
	
	public function get(index: Int): FastFloat;
		
	public function set(index: Int, value: FastFloat): FastFloat;
}

abstract Float32Array(Float32ArrayData) {
	public inline function new() {
		this = Float32ArrayData.create();
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		return this.set(index, value);
	}
	
	public inline function get(index: Int): FastFloat {
		return this.get(index);
	}
	
	@:arrayAccess
	public inline function arrayRead(index: Int): FastFloat {
		return this.get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: FastFloat): FastFloat {
		return this.set(index, value);
	}

	//public inline function subarray(start: Int, ?end: Int): Float32Array {
	//	return cast this.subarray(start, end);
	//}
}
