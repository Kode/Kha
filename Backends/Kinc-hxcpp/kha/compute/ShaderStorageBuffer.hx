package kha.compute;

import kha.graphics4.VertexData;

@:headerCode("
#include <kinc/compute/compute.h>
")
@:headerClassCode("
#ifdef KORE_OPENGL
Kore::ShaderStorageBuffer* buffer;
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
	Kore::Graphics4::VertexData type2;
	switch (type) {
	case 0:
		type2 = Kore::Graphics4::Float1VertexData;
		break;
	case 1:
		type2 = Kore::Graphics4::Float2VertexData;
		break;
	case 2:
		type2 = Kore::Graphics4::Float3VertexData;
		break;
	case 3:
		type2 = Kore::Graphics4::Float4VertexData;
		break;
	case 4:
		type2 = Kore::Graphics4::Float4x4VertexData;
		break;
	}
	buffer = new Kore::ShaderStorageBuffer(indexCount, type2);
	#endif
	")
	function init(indexCount: Int, type: VertexData) {
		myCount = indexCount;
		data = new Array<Int>();
		data[myCount - 1] = 0;
	}

	@:functionCode("
		#ifdef KORE_OPENGL
		delete buffer; buffer = nullptr;
		#endif
	")
	public function delete(): Void {}

	public function lock(): Array<Int> {
		return data;
	}

	@:functionCode("
		#ifdef KORE_OPENGL
		int* indices = buffer->lock();
		for (int i = 0; i < myCount; ++i) {
			indices[i] = data[i];
		}
		buffer->unlock();
		#endif
	")
	public function unlock(): Void {}

	public function count(): Int {
		return myCount;
	}
}
