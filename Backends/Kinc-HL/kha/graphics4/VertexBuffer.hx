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
			kore_vertexstructure_add(structure2, StringHelper.convert(vertexElement.name), convertVertexDataToKinc(vertexElement.data));
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

	/** Convert Kha vertex data enum values to Kinc enum values **/
	public static inline function convertVertexDataToKinc(data: VertexData): Int {
		return switch (data) {
			case Float32_1X: 1; // KINC_G4_VERTEX_DATA_F32_1X
			case Float32_2X: 2; // KINC_G4_VERTEX_DATA_F32_2X
			case Float32_3X: 3; // KINC_G4_VERTEX_DATA_F32_3X
			case Float32_4X: 4; // KINC_G4_VERTEX_DATA_F32_4X
			case Float32_4X4: 5; // KINC_G4_VERTEX_DATA_F32_4X4
			case Int8_1X: 6; // KINC_G4_VERTEX_DATA_I8_1X
			case UInt8_1X: 7; // KINC_G4_VERTEX_DATA_U8_1X
			case Int8_1X_Normalized: 8; // KINC_G4_VERTEX_DATA_I8_1X_NORMALIZED
			case UInt8_1X_Normalized: 9; // KINC_G4_VERTEX_DATA_U8_1X_NORMALIZED
			case Int8_2X: 10; // KINC_G4_VERTEX_DATA_I8_2X
			case UInt8_2X: 11; // KINC_G4_VERTEX_DATA_U8_2X
			case Int8_2X_Normalized: 12; // KINC_G4_VERTEX_DATA_I8_2X_NORMALIZED
			case UInt8_2X_Normalized: 13; // KINC_G4_VERTEX_DATA_U8_2X_NORMALIZED
			case Int8_4X: 14; // KINC_G4_VERTEX_DATA_I8_4X
			case UInt8_4X: 15; // KINC_G4_VERTEX_DATA_U8_4X
			case Int8_4X_Normalized: 16; // KINC_G4_VERTEX_DATA_I8_4X_NORMALIZED
			case UInt8_4X_Normalized: 17; // KINC_G4_VERTEX_DATA_U8_4X_NORMALIZED
			case Int16_1X: 18; // KINC_G4_VERTEX_DATA_I16_1X
			case UInt16_1X: 19; // KINC_G4_VERTEX_DATA_U16_1X
			case Int16_1X_Normalized: 20; // KINC_G4_VERTEX_DATA_I16_1X_NORMALIZED
			case UInt16_1X_Normalized: 21; // KINC_G4_VERTEX_DATA_U16_1X_NORMALIZED
			case Int16_2X: 22; // KINC_G4_VERTEX_DATA_I16_2X
			case UInt16_2X: 23; // KINC_G4_VERTEX_DATA_U16_2X
			case Int16_2X_Normalized: 24; // KINC_G4_VERTEX_DATA_I16_2X_NORMALIZED
			case UInt16_2X_Normalized: 25; // KINC_G4_VERTEX_DATA_U16_2X_NORMALIZED
			case Int16_4X: 26; // KINC_G4_VERTEX_DATA_I16_4X
			case UInt16_4X: 27; // KINC_G4_VERTEX_DATA_U16_4X
			case Int16_4X_Normalized: 28; // KINC_G4_VERTEX_DATA_I16_4X_NORMALIZED
			case UInt16_4X_Normalized: 29; // KINC_G4_VERTEX_DATA_U16_4X_NORMALIZED
			case Int32_1X: 30; // KINC_G4_VERTEX_DATA_I32_1X
			case UInt32_1X: 31; // KINC_G4_VERTEX_DATA_U32_1X
			case Int32_2X: 32; // KINC_G4_VERTEX_DATA_I32_2X
			case UInt32_2X: 33; // KINC_G4_VERTEX_DATA_U32_2X
			case Int32_3X: 34; // KINC_G4_VERTEX_DATA_I32_3X
			case UInt32_3X: 35; // KINC_G4_VERTEX_DATA_U32_3X
			case Int32_4X: 36; // KINC_G4_VERTEX_DATA_I32_4X
			case UInt32_4X: 37; // KINC_G4_VERTEX_DATA_U32_4X
		}
	}

	@:hlNative("std", "kinc_create_vertexstructure") public static function kore_create_vertexstructure(instanced: Bool): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_vertexstructure_add") public static function kore_vertexstructure_add(structure: Pointer, name: hl.Bytes, data: Int): Void {}

	@:hlNative("std", "kinc_create_vertexbuffer") static function kore_create_vertexbuffer(vertexCount: Int, structure: Pointer, usage: Int,
			stepRate: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_delete_vertexbuffer") static function kore_delete_vertexbuffer(buffer: Pointer): Void {}

	@:hlNative("std", "kinc_vertexbuffer_lock") static function kore_vertexbuffer_lock(buffer: Pointer): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_vertexbuffer_unlock") static function kore_vertexbuffer_unlock(buffer: Pointer, count: Int): Void {}

	@:hlNative("std", "kinc_vertexbuffer_stride") static function kore_vertexbuffer_stride(buffer: Pointer): Int {
		return 0;
	}

	@:hlNative("std", "kinc_vertexbuffer_count") static function kore_vertexbuffer_count(buffer: Pointer): Int {
		return 0;
	}
}
