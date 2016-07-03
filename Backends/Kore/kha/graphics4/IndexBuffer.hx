package kha.graphics4;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::IndexBuffer* buffer;")
class IndexBuffer {
	private var data: Array<Int>;
	private var myCount: Int;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		myCount = indexCount;
		data = new Array<Int>();
		data[myCount - 1] = 0;
		untyped __cpp__('buffer = new Kore::IndexBuffer(indexCount);');
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
