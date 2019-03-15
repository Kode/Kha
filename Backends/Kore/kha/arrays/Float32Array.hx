package kha.arrays;

import cpp.vm.Gc;
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
	function get_length(): Int;
	
	public function alloc(elements: Int): Void;

	public function free(): Void;

	public function get(index: Int): FastFloat;
		
	public function set(index: Int, value: FastFloat): FastFloat;
}

class Float32ArrayPrivate {
	public var self: Float32ArrayData;

	public inline function new(elements: Int = 0) {
		self = Float32ArrayData.create();
		if (elements > 0) {
			self.alloc(elements);
			Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
		}
	}

	@:void static function finalize(arr: Float32ArrayPrivate): Void {
		arr.self.free();
	}
}

abstract Float32Array(Float32ArrayPrivate) {
	public inline function new(elements: Int = 0) {
		this = new Float32ArrayPrivate(elements);
	}

	public inline function free(): Void {
		this.self.free();
	}

	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.self.length;
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		return this.self.set(index, value);
	}
	
	public inline function get(index: Int): FastFloat {
		return this.self.get(index);
	}
	
	@:arrayAccess
	public inline function arrayRead(index: Int): FastFloat {
		return this.self.get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: FastFloat): FastFloat {
		return this.self.set(index, value);
	}

	//public inline function subarray(start: Int, ?end: Int): Float32Array {
	//	return cast this.self.subarray(start, end);
	//}
}
