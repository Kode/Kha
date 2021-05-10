package kha.graphics4;

import kha.arrays.Float32Array;
import kha.arrays.Int16Array;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexStructure;

@:headerCode("
#include <kinc/graphics4/vertexbuffer.h>
")
@:headerClassCode("kinc_g4_vertex_buffer_t buffer;")
class VertexBuffer {
	var data: Float32Array;
	@:keep var dataInt16: Int16Array;

	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		init(vertexCount, structure, usage, instanceDataStepRate);
		data = new Float32Array();
	}

	public function delete(): Void {
		untyped __cpp__("kinc_g4_vertex_buffer_destroy(&buffer);");
	}

	@:functionCode("
		kinc_g4_vertex_structure_t structure2;
		kinc_g4_vertex_structure_init(&structure2);
		for (int i = 0; i < structure->size(); ++i) {
			kinc_g4_vertex_data_t data;
			switch (structure->get(i)->data) {
			case 0:
				data = KINC_G4_VERTEX_DATA_FLOAT1;
				break;
			case 1:
				data = KINC_G4_VERTEX_DATA_FLOAT2;
				break;
			case 2:
				data = KINC_G4_VERTEX_DATA_FLOAT3;
				break;
			case 3:
				data = KINC_G4_VERTEX_DATA_FLOAT4;
				break;
			case 4:
				data = KINC_G4_VERTEX_DATA_FLOAT4X4;
				break;
			case 5:
				data = KINC_G4_VERTEX_DATA_SHORT2_NORM;
				break;
			case 6:
				data = KINC_G4_VERTEX_DATA_SHORT4_NORM;
				break;
			}
			kinc_g4_vertex_structure_add(&structure2, structure->get(i)->name, data);
		}
		kinc_g4_vertex_buffer_init(&buffer, vertexCount, &structure2, (kinc_g4_usage_t)usage, instanceDataStepRate);
	")
	function init(vertexCount: Int, structure: VertexStructure, usage: Int, instanceDataStepRate: Int) {}

	@:functionCode("
		data->self.data = kinc_g4_vertex_buffer_lock(&buffer, start, count);
		data->self.myLength = count * kinc_g4_vertex_buffer_stride(&buffer) / 4;
		return data;
	")
	function lockPrivate(start: Int, count: Int): Float32Array {
		return data;
	}

	var lastLockCount: Int = 0;

	public function lock(?start: Int, ?count: Int): Float32Array {
		if (start == null)
			start = 0;
		if (count == null)
			count = this.count();
		lastLockCount = count;
		return lockPrivate(start, count);
	}

	@:functionCode("
		dataInt16->self.data = (short*)kinc_g4_vertex_buffer_lock(&buffer, start, count);
		dataInt16->self.myLength = count * kinc_g4_vertex_buffer_stride(&buffer) / 2;
		return dataInt16;
	")
	function lockInt16Private(start: Int, count: Int): Int16Array {
		return dataInt16;
	}

	public function lockInt16(?start: Int, ?count: Int): Int16Array {
		if (start == null)
			start = 0;
		if (count == null)
			count = this.count();
		lastLockCount = count;
		if (dataInt16 == null)
			dataInt16 = new Int16Array();
		return lockInt16Private(start, count);
	}

	@:functionCode("kinc_g4_vertex_buffer_unlock(&buffer, count); data->self.data = nullptr; if (!hx::IsNull(dataInt16)) dataInt16->self.data = nullptr;")
	function unlockPrivate(count: Int): Void {}

	public function unlock(?count: Int): Void {
		unlockPrivate(count == null ? lastLockCount : count);
	}

	@:functionCode("return kinc_g4_vertex_buffer_stride(&buffer);")
	public function stride(): Int {
		return 0;
	}

	@:functionCode("return kinc_g4_vertex_buffer_count(&buffer);")
	public function count(): Int {
		return 0;
	}

	@:noCompletion
	@:keep
	public static function _unused1(): VertexElement {
		return null;
	}

	@:noCompletion
	@:keep
	public static function _unused2(): VertexData {
		return VertexData.Float1;
	}
}
