package kha.arrays;

@:unreflective
@:structAccess
@:include("cpp_bytearray.h")
@:native("bytearray")
extern class ByteBuffer {
	@:native("bytearray")
	public static function create(): ByteBuffer;

	public var byteLength(get, never): Int;

	@:native("byteLength")
	function get_byteLength(): Int;

	public function slice(begin: Int, end: Int): ByteBuffer;

	public function alloc(elements: Int): Void;

	public function free(): Void;

	public function get(index: Int): FastFloat;

	public function set(index: Int, value: FastFloat): FastFloat;
}
