package kha.arrays;

import cpp.vm.Gc;
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
	function get_length(): Int;

	public function alloc(elements: Int): Void;

	public function free(): Void;

	public function get(index: Int): Int;

	public function set(index: Int, value: Int): Int;
}

class Uint32ArrayPrivate {
	public var self: Uint32ArrayData;

	public inline function new(elements: Int = 0) {
		self = Uint32ArrayData.create();
		if (elements > 0) {
			self.alloc(elements);
		}

		Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
	}

	@:void static function finalize(arr: Uint32ArrayPrivate): Void {
		arr.self.free();
	}
}

abstract Uint32Array(Uint32ArrayPrivate) {
	public inline function new(elements: Int = 0) {
		this = new Uint32ArrayPrivate(elements);
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

	// public inline function subarray(start: Int, ?end: Int): Uint32Array {
	//	return cast this.self.subarray(start, end);
	// }
}
