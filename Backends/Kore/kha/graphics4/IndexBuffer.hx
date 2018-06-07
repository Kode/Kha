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
		data->self.data = (unsigned int*)buffer->lock() + start;
		data->self.myLength = count;
		return data;
	')
	private function lock2(start: Int, count: Int): Uint32Array {
		return data;
	}

	public function lock(?start: Int, ?count: Int): Uint32Array {
		if (start == null) start = 0;
		if (count == null) count = this.count();
		return lock2(start, count);
	}
	
	@:functionCode('buffer->unlock();')
	public function unlock(): Void {
		
	}
	
	public function count(): Int {
		return myCount;
	}
}
