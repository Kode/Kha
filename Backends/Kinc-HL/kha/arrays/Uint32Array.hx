package kha.arrays;

class Uint32ArrayPrivate {
	// Has to be wrapped in class..
	public var self: Pointer;
	public var length: Int;

	public inline function new() {}
}

abstract Uint32Array(Uint32ArrayPrivate) {
	public inline function new(elements: Int = 0) {
		this = new Uint32ArrayPrivate();
		this.length = elements;
		if (elements > 0)
			this.self = kore_uint32array_alloc(elements);
	}

	public inline function free(): Void {
		kore_uint32array_free(this.self);
	}

	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}

	public inline function getData(): Pointer {
		return this.self;
	}

	public inline function setData(ar: Pointer, elements: Int): Void {
		this.self = ar;
		this.length = elements;
	}

	public inline function set(index: Int, value: Int): Int {
		kore_uint32array_set(this.self, index, value);
		return value;
	}

	public inline function get(index: Int): Int {
		return kore_uint32array_get(this.self, index);
	}

	@:arrayAccess
	public inline function arrayRead(index: Int): Int {
		return get(index);
	}

	@:arrayAccess
	public inline function arrayWrite(index: Int, value: Int): Int {
		return set(index, value);
	}

	@:hlNative("std", "kore_uint32array_alloc") static function kore_uint32array_alloc(elements: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kore_uint32array_free") static function kore_uint32array_free(u32array: Pointer): Void {}

	@:hlNative("std", "kore_uint32array_set") static function kore_uint32array_set(u32array: Pointer, index: Int, value: Int): Void {}

	@:hlNative("std", "kore_uint32array_get") static function kore_uint32array_get(u32array: Pointer, index: Int): Int {
		return 0;
	}
}
