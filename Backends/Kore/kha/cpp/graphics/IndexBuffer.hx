package kha.cpp.graphics;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::IndexBuffer* buffer;")
class IndexBuffer implements kha.graphics.IndexBuffer{
	private var data: Array<Int>;
	private var myCount: Int;
	
	public function new(indexCount: Int) {
		myCount = indexCount;
		data = new Array<Int>();
		data[myCount - 1] = 0;
		init(indexCount);
	}
	
	@:functionCode('
		buffer = new Kore::IndexBuffer(count);
	')
	private function init(count: Int) {
		
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
	
	@:functionCode("
		buffer->set();
	")
	public function set(): Void {
		
	}
	
	public function count(): Int {
		return myCount;
	}
}
