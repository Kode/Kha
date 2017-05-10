package kha.graphics4;

import kha.arrays.Uint32Array;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
')

@:headerClassCode("Kore::Graphics4::IndexBuffer* buffer;")
class IndexBuffer {
	private var data: Uint32Array;
	private var myCount: Int;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		myCount = indexCount;
		data = new Uint32Array();
		untyped __cpp__('buffer = new Kore::Graphics4::IndexBuffer(indexCount);');
	}
	
	public function delete(): Void {
		untyped __cpp__('delete buffer; buffer = nullptr;');
	}
	
	@:functionCode('
		data.data = (unsigned int*)buffer->lock();
		data.myLength = buffer->count();
		return data;
	')
	public function lock(?start: Int, ?count: Int): Uint32Array {
		return data;
	}
	
	@:functionCode('buffer->unlock();')
	public function unlock(): Void {
		
	}
	
	public function count(): Int {
		return myCount;
	}
}
