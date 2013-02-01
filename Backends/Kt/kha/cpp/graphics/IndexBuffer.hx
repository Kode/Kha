package kha.cpp.graphics;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Graphics.h>
')

@:headerClassCode("Kt::IndexBuffer* buffer;")
class IndexBuffer implements kha.graphics.IndexBuffer{
	private var data: Array<Int>;
	
	public function new(indexCount: Int) {
		
	}
	
	@:functionCode("
		buffer->lock();
	")
	public function lock(): Array<Int> {
		return data;
	}
	
	
	@:functionCode("
		buffer->unlock();
	")
	public function unlock(): Void {
		
	}
	
	@:functionCode("
		buffer->set();
	")
	public function set(): Void {
		
	}
}