package kha.compute;

import kha.graphics4.VertexData;

@:headerCode("
#include <kinc/compute/compute.h>
")
@:headerClassCode("
#ifdef KORE_OPENGL
kinc_shader_storage_buffer buffer;
#endif")
class ShaderStorageBuffer {
	var data: Array<Int>;
	var myCount: Int;

	public function new(indexCount: Int, type: VertexData) {
		myCount = indexCount;
		data = new Array<Int>();
		data[myCount - 1] = 0;
		init(indexCount, type);
	}

	@:functionCode("
	#ifdef KORE_OPENGL
	kinc_g4_vertex_data type2;
	switch (type) {
	case 0:
		type2 = KINC_G4_VERTEX_DATA_FLOAT1;
		break;
	case 1:
		type2 = KINC_G4_VERTEX_DATA_FLOAT2;
		break;
	case 2:
		type2 = KINC_G4_VERTEX_DATA_FLOAT3;
		break;
	case 3:
		type2 = KINC_G4_VERTEX_DATA_FLOAT4;
		break;
	case 4:
		type2 = KINC_G4_VERTEX_DATA_FLOAT4X4;
		break;
	}
	kinc_shader_storage_buffer_init(&buffer, indexCount, type2);
	#endif
	")
	function init(indexCount: Int, type: VertexData) {
		myCount = indexCount;
		data = new Array<Int>();
		data[myCount - 1] = 0;
	}

	@:functionCode("
		#ifdef KORE_OPENGL
		kinc_shader_storage_buffer_destroy(&buffer);
		#endif
	")
	public function delete(): Void {}

	public function lock(): Array<Int> {
		return data;
	}

	@:functionCode("
		#ifdef KORE_OPENGL
		int* indices = kinc_shader_storage_buffer_lock(&buffer);
		for (int i = 0; i < myCount; ++i) {
			indices[i] = data[i];
		}
		kinc_shader_storage_buffer_unlock(&buffer);
		#endif
	")
	public function unlock(): Void {}

	public function count(): Int {
		return myCount;
	}
}
