package kha.arrays;

import cpp.vm.Gc;
import haxe.ds.Vector;

@:unreflective
@:structAccess
@:include("cpp_int16array.h")
@:native("int16array")
extern class Int16ArrayData {
	@:native("int16array")
	public static function create(): Int16ArrayData;
	
	public var length(get, never): Int;

	@:native("length")
	function get_length(): Int;

	public function alloc(elements: Int): Void;

	public function free(): Void;
	
	public function get(index: Int): Int;
		
	public function set(index: Int, value: Int): Int;
}

class Int16ArrayPrivate {
	public var self: Int16ArrayData;

	public inline function new(elements: Int = 0) {
		self = Int16ArrayData.create();
		if (elements > 0) {
			self.alloc(elements);
			Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
		}
	}

	@:void static function finalize(arr: Int16ArrayPrivate): Void {
		arr.self.free();
	}
}

abstract Int16Array(Int16ArrayPrivate) {
	public inline function new(elements: Int = 0) {
		this = new Int16ArrayPrivate(elements);
	}

	public inline function free(): Void {
		this.self.free();
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.self.length;
	}
	
	public inline function set(index: Int, value: Int): Int {
		return this.self.set(index, value);
	}
	
	public inline function get(index: Int): Int {
		return this.self.get(index);
	}
	
	@:arrayAccess
	public inline function arrayRead(index: Int): Int {
		return this.self.get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: Int): Int {
		return this.self.set(index, value);
	}

	//public inline function subarray(start: Int, ?end: Int): Int16Array {
	//	return cast this.self.subarray(start, end);
	//}
}
