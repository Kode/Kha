package kha.arrays;

abstract ByteBuffer(Pointer) from Pointer to Pointer {
	function new(bytearray: Pointer) {
		this = bytearray;
	}

	public static function create(length: Int): ByteBuffer {
		return new ByteBuffer(kore_bytebuffer_alloc(length));
	}

	public function free() {
		kore_bytebuffer_free(this);
	}

	@:hlNative("std", "kinc_bytebuffer_alloc") static function kore_bytebuffer_alloc(elements: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_bytebuffer_free") static function kore_bytebuffer_free(bytearray: Pointer) {}
}
