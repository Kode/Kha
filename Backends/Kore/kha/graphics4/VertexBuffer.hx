package kha.graphics4;

import kha.arrays.Float32Array;
import kha.arrays.Int16Array;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexStructure;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
')

@:headerClassCode("Kore::Graphics4::VertexBuffer* buffer;")
class VertexBuffer {
	private var data: Float32Array;
	private var dataInt16: Int16Array;

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
			case 5:
				data = Kore::Graphics4::Short2NormVertexData;
				break;
			case 6:
				data = Kore::Graphics4::Short4NormVertexData;
				break;
			}
			structure2.add(structure->get(i)->name, data);
		}
		buffer = new Kore::Graphics4::VertexBuffer(vertexCount, structure2, (Kore::Graphics4::Usage)usage, instanceDataStepRate);
	")
	private function init(vertexCount: Int, structure: VertexStructure, usage: Int, instanceDataStepRate: Int) {

	}

	@:functionCode('
		data->self.data = buffer->lock() + start * buffer->stride() / 4;
		data->self.myLength = count * buffer->stride() / 4;
		return data;
	')
	private function lockPrivate(start: Int, count: Int): Float32Array {
		return data;
	}

	var lastLockCount: Int = 0;

	public function lock(?start: Int, ?count: Int): Float32Array {
		if (start == null) start = 0;
		if (count == null) count = this.count();
		lastLockCount = count;
		return lockPrivate(start, count);
	}

	@:functionCode('
		dataInt16->self.data = (short*)buffer->lock() + start * buffer->stride() / 2;
		dataInt16->self.myLength = count * buffer->stride() / 2;
		return dataInt16;
	')
	private function lockInt16Private(start: Int, count: Int): Int16Array {
		return dataInt16;
	}

	public function lockInt16(?start: Int, ?count: Int): Int16Array {
		if (start == null) start = 0;
		if (count == null) count = this.count();
		if (dataInt16 == null) dataInt16 = new Int16Array();
		return lockInt16Private(start, count);
	}

	@:functionCode('buffer->unlock(count);')
	function unlockPrivate(count: Int): Void {

	}

	public function unlock(?count: Int): Void {
		unlockPrivate(count == null ? lastLockCount : count);
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
		return VertexData.Float1;
	}
}
