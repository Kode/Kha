package kha.compute;

import kha.graphics4.VertexData;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Compute/Compute.h>
')

@:headerClassCode("Kore::ShaderStorageBuffer* buffer;")
class ShaderStorageBuffer {
	private var data: Array<Int>;
	private var myCount: Int;
	
	public function new(indexCount: Int, type: VertexData) {
		myCount = indexCount;
		data = new Array<Int>();
		data[myCount - 1] = 0;
    init(indexCount, type);
	}
  
  @:functionCode("
		Kore::Graphics4::VertexData type2;
    switch (type->index) {
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
	")
	private function init(indexCount: Int, type: VertexData) {
		myCount = indexCount;
		data = new Array<Int>();
		data[myCount - 1] = 0;
	}
	
	public function delete(): Void {
		untyped __cpp__('delete buffer; buffer = nullptr;');
	}
	
	public function lock(): Array<Int> {
		return data;
	}
	
	@:functionCode("
		int* indices = buffer->lock();
		for (int i = 0; i < myCount; ++i) {
			indices[i] = data[i];
		}
		buffer->unlock();
	")
	public function unlock(): Void {
		
	}
	
	public function count(): Int {
		return myCount;
	}
}
