package kha.arrays;

@:unreflective
@:structAccess
@:include("cpp_bytearray.h")
@:native("bytearray")
class ByteBuffer {
	function create(length: Int): ByteBuffer;

	var byteLength(get, null): Int;

	function slice(begin: Int, ?end: Int): ByteBuffer;
}
