package kha.arrays;

import cpp.vm.Gc;
import haxe.ds.Vector;

@:unreflective
@:structAccess
@:include("cpp_uint8array.h")
@:native("uint8array")
extern class Uint8ArrayData {
	@:native("uint8array")
	public static function create(): Uint8ArrayData;

	public var length(get, never): Int;

	@:native("length")
	function get_length(): Int;

	public function alloc(elements: Int): Void;

	public function free(): Void;

	public function get(index: Int): Int;

	public function set(index: Int, value: Int): Int;
}

class Uint8ArrayPrivate {
	public var self: Uint8ArrayData;

	public inline function new(elements: Int = 0) {
		self = Uint8ArrayData.create();
		if (elements > 0) {
			self.alloc(elements);
		}

		Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
	}

	@:void static function finalize(arr: Uint8ArrayPrivate): Void {
		arr.self.free();
	}
}

abstract Uint8Array(Uint8ArrayPrivate) {
	public inline function new(elements: Int = 0) {
		this = new Uint8ArrayPrivate(elements);
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

	// public inline function subarray(start: Int, ?end: Int): Uint8Array {
	//	return cast this.self.subarray(start, end);
	// }
}
