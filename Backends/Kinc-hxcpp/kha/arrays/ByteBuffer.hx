package kha.arrays;

@:unreflective
@:structAccess
@:include("cpp_bytearray.h")
@:native("bytearray")
extern class ByteBuffer {
	@:native("bytearray")
	public static function create(): ByteBuffer;

	public function alloc(length: Int): Void;

	public function addRef(): Void;

	public function subRef(): Void;

	public function get(index: Int): FastFloat;

	public function set(index: Int, value: FastFloat): FastFloat;
}
