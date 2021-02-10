package kha.graphics5;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics5/ConstantBuffer.h>
')

@:headerClassCode("Kore::Graphics5::ConstantBuffer* buffer;")
class ConstantBuffer {
	
	public function new(size: Int) {
		init(size);
	}

	function init(size: Int) {
		untyped __cpp__("buffer = new Kore::Graphics5::ConstantBuffer(size)");
	}

	public function lock(): Void {
		untyped __cpp__("buffer->lock()");
	}

	public function unlock(): Void {
		untyped __cpp__("buffer->unlock()");
	}

	public function setFloat(offset: Int, value: FastFloat): Void {
		untyped __cpp__("buffer->setFloat(offset, value)");
	}
}
