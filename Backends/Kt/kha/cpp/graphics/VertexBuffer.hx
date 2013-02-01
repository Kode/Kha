package kha.cpp.graphics;

import kha.graphics.VertexStructure;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Graphics.h>
')

@:headerClassCode("Kt::VertexBuffer* buffer;")
class VertexBuffer implements kha.graphics.VertexBuffer {
	private var myStride: Int;
	private var mySize: Int;
	
	public function new(vertexCount: Int, structure: VertexStructure) {
		
	}
	
	@:functionCode("
		buffer->lock(start, count);
	")
	public function lock(?start: Int, ?count: Int): Array<Float> {
		return null;
	}
	
	@:functionCode("
		buffer->unlock();
	")
	public function unlock(): Void {
		
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function size(): Int {
		return mySize;
	}
	
	@:functionCode("
		buffer->set();
	")
	public function bind(program: Dynamic): Void {
		
	}
}