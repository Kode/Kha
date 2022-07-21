package kha.graphics4;

import haxe.io.Bytes;
import haxe.io.BytesData;

class IndexBuffer {
	public var _buffer: Pointer;

	var myCount: Int;

	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		myCount = indexCount;
		_buffer = kinc_create_indexbuffer(indexCount);
	}

	public function delete() {
		kinc_delete_indexbuffer(_buffer);
	}

	public function lock(?start: Int, ?count: Int): kha.arrays.Uint32Array {
		return cast new kha.arrays.ByteArray(kinc_indexbuffer_lock(_buffer), 0, myCount * 4);
	}

	public function unlock(?count: Int): Void {
		kinc_indexbuffer_unlock(_buffer);
	}

	public function count(): Int {
		return myCount;
	}

	@:hlNative("std", "kinc_create_indexbuffer") static function kinc_create_indexbuffer(count: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_delete_indexbuffer") static function kinc_delete_indexbuffer(buffer: Pointer): Void {}

	@:hlNative("std", "kinc_indexbuffer_lock") static function kinc_indexbuffer_lock(buffer: Pointer): hl.Bytes {
		return null;
	}

	@:hlNative("std", "kinc_indexbuffer_unlock") static function kinc_indexbuffer_unlock(buffer: Pointer): Void {}
}
