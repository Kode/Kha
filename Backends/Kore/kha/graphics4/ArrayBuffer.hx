package kha.graphics4;
import kha.arrays.Float32Array;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::ArrayBuffer* buffer;")
class ArrayBuffer {
	private var data: Float32Array;
	private var myCount: Int;
	
	public function new(indexCount: Int, structureSize: Int, structureCount: Int, usage: Usage) {
		myCount = indexCount;
		data = new Float32Array();
		init(indexCount, structureSize, structureCount);
	}
	
	@:functionCode('
		buffer = new Kore::ArrayBuffer(indexCount, structureSize, structureCount);
	')
	private function init(indexCount: Int, structureSize: Int, structureCount: Int) {
		
	}
	
	@:functionCode('
		data->data.data = buffer->lock();
		data->data.myLength = buffer->count() / 4;
		return data;
	')
	public function lock(): Float32Array {
		return data;
	}
	
	@:functionCode('buffer->unlock();')
	public function unlock(): Void {
		
	}
	
	@:functionCode("
		buffer->set((AttributeLocation) location, divisor);
	")
	public function set(location: AttributeLocation, divisor: Int): Void {
		
	}
	
	public function count(): Int {
		return myCount;
	}
}
