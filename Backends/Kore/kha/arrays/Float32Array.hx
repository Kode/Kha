package kha.arrays;

import cpp.RawPointer;
import haxe.ds.Vector;
import kha.FastFloat;

@:unreflective
@:structAccess
@:include("float32array.h")
@:native("float32array")
extern class Float32ArrayData {
	@:native("float32array")
	public static function create(): Float32Array;
	
	public var length(get, never): Int;

	@:native("length")
	function get_length(): Int {
		return 0;
	}
	
	public function get(index: Int): FastFloat;
		
	public function set(index: Int, value: FastFloat): FastFloat;
}

class Float32Array {
	private var data: Float32ArrayData;
	
	public inline function new() {
		
	}
	
	public var length(get, never): Int;

	private inline function get_length(): Int {
		return data.length;
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		return data.set(index, value);
	}
	
	public inline function get(index: Int): FastFloat {
		return data.get(index);
	}
}
