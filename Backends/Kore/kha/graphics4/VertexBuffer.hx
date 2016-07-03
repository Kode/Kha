package kha.graphics4;

import kha.arrays.Float32Array;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexStructure;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::VertexBuffer* buffer;")
class VertexBuffer {
	private var data: Float32Array;
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		init(vertexCount, structure, instanceDataStepRate);
		data = new Float32Array();
		var a: VertexElement = new VertexElement("a", VertexData.Float2); //to generate include
	}
	
	public function delete(): Void {
		untyped __cpp__('delete buffer; buffer = nullptr;');
	}
	
	@:functionCode("
		Kore::VertexStructure structure2;
		for (int i = 0; i < structure->size(); ++i) {
			Kore::VertexData data;
			switch (structure->get(i)->data->index) {
			case 0:
				data = Kore::Float1VertexData;
				break;
			case 1:
				data = Kore::Float2VertexData;
				break;
			case 2:
				data = Kore::Float3VertexData;
				break;
			case 3:
				data = Kore::Float4VertexData;
				break;
			case 4:
				data = Kore::Float4x4VertexData;
				break;
			}
			structure2.add(structure->get(i)->name, data);
		}
		buffer = new Kore::VertexBuffer(vertexCount, structure2, instanceDataStepRate);
	")
	private function init(vertexCount: Int, structure: VertexStructure, instanceDataStepRate: Int) {
		
	}
	
	@:functionCode('
		data->data.data = buffer->lock();
		data->data.myLength = buffer->count() * buffer->stride() / 4;
		return data;
	')
	public function lock(?start: Int, ?count: Int): Float32Array {
		return data;
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
}
