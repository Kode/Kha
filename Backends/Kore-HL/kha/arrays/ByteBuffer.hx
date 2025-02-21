package kha.arrays;

abstract ByteBuffer(Pointer) from Pointer to Pointer {
	function new(bytearray: Pointer) {
		this = bytearray;
	}

	public static function create(length: Int): ByteBuffer {
		return new ByteBuffer(kinc_bytebuffer_alloc(length));
	}

	public function free() {
		kinc_bytebuffer_free(this);
	}

	@:hlNative("std", "kinc_bytebuffer_alloc") static function kinc_bytebuffer_alloc(elements: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_bytebuffer_free") static function kinc_bytebuffer_free(bytearray: Pointer) {}
}
