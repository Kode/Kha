package kha.cpp.graphics;

import kha.graphics.VertexData;
import kha.graphics.VertexElement;
import kha.graphics.VertexStructure;
import kha.graphics.VertexType;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Graphics.h>
')

@:headerClassCode("Kt::VertexBuffer* buffer;")
class VertexBuffer implements kha.graphics.VertexBuffer {
	private var data: Array<Float>;
	
	public function new(vertexCount: Int, structure: VertexStructure) {
		init(vertexCount, structure);
		data = new Array<Float>();
		data[stride() * size() - 1] = 0;
		var a = new VertexElement("a", VertexData.Float2, VertexType.Position);
	}
	
	@:functionCode("
		Kt::VertexStructure structure2;
		for (int i = 0; i < structure->elements->size(); ++i) {
			Kt::VertexData data;
			switch (structure->elements[i]->data->index) {
			case 0:
				data = Kt::Float2VertexData;
				break;
			case 1:
				data = Kt::Float3VertexData;
				break;
			}
			Kt::VertexType type;
			switch (structure->elements[i]->type->index) {
			case 0:
				type = Kt::PositionVertexType;
				break;
			case 1:
				type = Kt::ColorVertexType;
				break;
			case 2:
				type = Kt::TexCoordVertexType;
				break;
			}
			structure2.add(Kt::Text(structure->elements[i]->name), data, type);
		}
		buffer = Kt::Graphics::createVertexBuffer(vertexCount, structure2);
	")
	private function init(vertexCount: Int, structure: VertexStructure) {
		
	}
	
	public function lock(?start: Int, ?count: Int): Array<Float> {
		return data;
	}
	
	@:functionCode("
		float* vertices = buffer->lock();
		for (int i = 0; i < buffer->count * buffer->stride; ++i) {
			vertices[i] = data[i];
		}
		buffer->unlock();
	")
	public function unlock(): Void {
		
	}
	
	@:functionCode("
		return buffer->stride;
	")
	public function stride(): Int {
		return 0;
	}
	
	@:functionCode("
		return buffer->count;
	")
	public function size(): Int {
		return 0;
	}
	
	@:functionCode("
		buffer->set();
	")
	public function set(): Void {
		
	}
}