package kha.graphics4;

import kha.arrays.ByteArray;
import kha.arrays.Float32Array;
import kha.arrays.Int16Array;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexStructure;

class VertexBuffer {
	public var _buffer: Pointer;

	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		var structure2 = kore_create_vertexstructure(structure.instanced);
		for (i in 0...structure.size()) {
			var vertexElement = structure.get(i);
			kore_vertexstructure_add(structure2, StringHelper.convert(vertexElement.name), vertexElement.data);
		}
		_buffer = kore_create_vertexbuffer(vertexCount, structure2, usage, instanceDataStepRate);
	}

	public function delete() {
		kore_delete_vertexbuffer(_buffer);
	}

	public function lock(?start: Int, ?count: Int): Float32Array {
		return cast new ByteArray(kore_vertexbuffer_lock(_buffer), 0, this.count() * stride());
	}

	public function lockInt16(?start: Int, ?count: Int): Int16Array {
		return cast new ByteArray(kore_vertexbuffer_lock(_buffer), 0, this.count() * stride());
	}

	public function unlock(?count: Int): Void {
		kore_vertexbuffer_unlock(_buffer, count == null ? this.count() : count);
	}

	public function stride(): Int {
		return kore_vertexbuffer_stride(_buffer);
	}

	public function count(): Int {
		return kore_vertexbuffer_count(_buffer);
	}

	@:hlNative("std", "kore_create_vertexstructure") public static function kore_create_vertexstructure(instanced: Bool): Pointer {
		return null;
	}

	@:hlNative("std", "kore_vertexstructure_add") public static function kore_vertexstructure_add(structure: Pointer, name: hl.Bytes, data: Int): Void {}

	@:hlNative("std", "kore_create_vertexbuffer") static function kore_create_vertexbuffer(vertexCount: Int, structure: Pointer, usage: Int,
			stepRate: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kore_delete_vertexbuffer") static function kore_delete_vertexbuffer(buffer: Pointer): Void {}

	@:hlNative("std", "kore_vertexbuffer_lock") static function kore_vertexbuffer_lock(buffer: Pointer): Pointer {
		return null;
	}

	@:hlNative("std", "kore_vertexbuffer_unlock") static function kore_vertexbuffer_unlock(buffer: Pointer, count: Int): Void {}

	@:hlNative("std", "kore_vertexbuffer_stride") static function kore_vertexbuffer_stride(buffer: Pointer): Int {
		return 0;
	}

	@:hlNative("std", "kore_vertexbuffer_count") static function kore_vertexbuffer_count(buffer: Pointer): Int {
		return 0;
	}
}
