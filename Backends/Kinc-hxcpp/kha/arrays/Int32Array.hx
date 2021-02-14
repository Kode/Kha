package kha.arrays;

import cpp.vm.Gc;
import haxe.ds.Vector;

@:unreflective
@:structAccess
@:include("cpp_int32array.h")
@:native("int32array")
extern class Int32ArrayData {
	@:native("int32array")
	public static function create(): Int32ArrayData;

	public var length(get, never): Int;

	@:native("length")
	function get_length(): Int;

	public function alloc(elements: Int): Void;

	public function free(): Void;

	public function get(index: Int): Int;

	public function set(index: Int, value: Int): Int;
}

class Int32ArrayPrivate {
	public var self: Int32ArrayData;

	public inline function new(elements: Int = 0) {
		self = Int32ArrayData.create();
		if (elements > 0) {
			self.alloc(elements);
		}

		Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
	}

	@:void static function finalize(arr: Int32ArrayPrivate): Void {
		arr.self.free();
	}
}

abstract Int32Array(Int32ArrayPrivate) {
	public inline function new(elements: Int = 0) {
		this = new Int32ArrayPrivate(elements);
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

	// public inline function subarray(start: Int, ?end: Int): Int16Array {
	//	return cast this.self.subarray(start, end);
	// }
}
