package kha.arrays;

import kha.FastFloat;

class Float32ArrayPrivate {
	// Has to be wrapped in class..
	public var self: Pointer;
	public var length: Int;
	public inline function new() {}
}

abstract Float32Array(Float32ArrayPrivate) {
	
	public inline function new(elements: Int = 0) {
		this = new Float32ArrayPrivate();
		this.length = elements;
		if (elements > 0) this.self = kore_float32array_alloc(elements);
	}

	public inline function free(): Void {
		kore_float32array_free(this.self);
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}

	public inline function getData():Pointer {
		return this.self;
	}

	public inline function setData(ar:Pointer, elements: Int): Void {
		this.self = ar;
		this.length = elements;
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		kore_float32array_set(this.self, index, value);
		return value;
	}
	
	public inline function get(index: Int): FastFloat {
		return kore_float32array_get(this.self, index);
	}

	@:arrayAccess
	public inline function arrayRead(index: Int): FastFloat {
		return get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: FastFloat): FastFloat {
		return set(index, value);
	}

	@:hlNative("std", "kore_float32array_alloc") static function kore_float32array_alloc(elements: Int): Pointer { return null; }
	@:hlNative("std", "kore_float32array_free") static function kore_float32array_free(f32array: Pointer): Void { }
	@:hlNative("std", "kore_float32array_set") static function kore_float32array_set(f32array: Pointer, index: Int, value: FastFloat): Void { }
	@:hlNative("std", "kore_float32array_get") static function kore_float32array_get(f32array: Pointer, index: Int): FastFloat { return 0.0; }
}
