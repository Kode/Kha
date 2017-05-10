package kha.arrays;

import cpp.RawPointer;
import haxe.ds.Vector;

@:unreflective
@:structAccess
@:include("cpp_uint32array.h")
@:native("uint32array")
extern class Uint32ArrayData {
	@:native("uint32array")
	public static function create(): Uint32ArrayData;
	
	public var length(get, never): Int;

	@:native("length")
	function get_length(): Int {
		return 0;
	}
	
	public function get(index: Int): Int;
		
	public function set(index: Int, value: Int): Int;
}

abstract Uint32Array(Uint32ArrayData) {
	public inline function new() {
		this = Uint32ArrayData.create();
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}
	
	public inline function set(index: Int, value: Int): Int {
		return this.set(index, value);
	}
	
	public inline function get(index: Int): Int {
		return this.get(index);
	}
	
	@:arrayAccess
	public inline function arrayRead(index: Int): Int {
		return this.get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: Int): Int {
		return this.set(index, value);
	}

	//public inline function subarray(start: Int, ?end: Int): Uint32Array {
	//	return cast this.subarray(start, end);
	//}
}
