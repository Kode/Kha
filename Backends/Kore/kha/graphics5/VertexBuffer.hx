package kha.graphics5;

import kha.arrays.Float32Array;
import kha.graphics5.VertexData;
import kha.graphics5.VertexElement;
import kha.graphics5.VertexStructure;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics5/Graphics.h>
')

@:headerClassCode("Kore::Graphics5::VertexBuffer* buffer;")
class VertexBuffer {
	private var data: Float32Array;

	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		init(vertexCount, structure, usage, instanceDataStepRate);
		data = new Float32Array();
	}

	public function delete(): Void {
		untyped __cpp__('delete buffer; buffer = nullptr;');
	}

	@:functionCode("
		Kore::Graphics4::VertexStructure structure2;
		for (int i = 0; i < structure->size(); ++i) {
			Kore::Graphics4::VertexData data;
			switch (structure->get(i)->data) {
			case 0:
				data = Kore::Graphics4::Float1VertexData;
				break;
			case 1:
				data = Kore::Graphics4::Float2VertexData;
				break;
			case 2:
				data = Kore::Graphics4::Float3VertexData;
				break;
			case 3:
				data = Kore::Graphics4::Float4VertexData;
				break;
			case 4:
				data = Kore::Graphics4::Float4x4VertexData;
				break;
			}
			structure2.add(structure->get(i)->name, data);
		}
		buffer = new Kore::Graphics5::VertexBuffer(vertexCount, structure2, false);
	")
	private function init(vertexCount: Int, structure: VertexStructure, usage: Int, instanceDataStepRate: Int) {

	}

	@:functionCode('
		data->self.data = buffer->lock() + start * buffer->stride() / 4;
		data->self.myLength = count * buffer->stride() / 4;
		return data;
	')
	private function lock2(start: Int, count: Int): Float32Array {
		return data;
	}

	public function lock(?start: Int, ?count: Int): Float32Array {
		if (start == null) start = 0;
		if (count == null) count = this.count();
		return lock2(start, count);
	}

	@:functionCode('buffer->unlock();')
	public function unlock(): Void {

	}

	@:functionCode("return buffer->stride();")
	public function stride(): Int {
		return 0;
	}

	@:functionCode("return buffer->count();")
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
		return Float1;
	}
}
