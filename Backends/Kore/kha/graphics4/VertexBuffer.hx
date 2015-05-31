package kha.graphics4;

import haxe.io.BytesData;
import haxe.io.Float32Array;
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
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false) {
		init(vertexCount, structure);
		data = new Float32Array(Std.int(stride() / 4) * count());
		
		var a: VertexElement = new VertexElement("a", VertexData.Float2); //to generate include
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
			}
			structure2.add(structure->get(i)->name, data);
		}
		buffer = new Kore::VertexBuffer(vertexCount, structure2);
	")
	private function init(vertexCount: Int, structure: VertexStructure) {
		
	}
	
	public function lock(?start: Int, ?count: Int): Float32Array {
		return data;
	}
	
	@:functionCode("
		float* vertices = buffer->lock();
		float* pointer = (float*)bytes->Pointer();
		for (int i = 0; i < buffer->count() * buffer->stride() / 4; ++i) {
			vertices[i] = pointer[i];
		}
		buffer->unlock();
	")
	private function unlock2(bytes: BytesData): Void {
		
	}
	
	public function unlock(): Void {
		unlock2(data.getData().bytes.getData());
	}
	
	@:functionCode("
		return buffer->stride();
	")
	public function stride(): Int {
		return 0;
	}
	
	@:functionCode("
		return buffer->count();
	")
	public function count(): Int {
		return 0;
	}
	
	@:functionCode("
		buffer->set();
	")
	public function set(): Void {
		
	}
}
