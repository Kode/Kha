package kha.js.graphics;

import kha.graphics.Usage;

class IndexBuffer implements kha.graphics.IndexBuffer {
	private var buffer: Dynamic;
	private var data: Array<Int>;
	private var mySize: Int;
	private var usage: Usage;
	
	public function new(indexCount: Int, usage: Usage) {
		this.usage = usage;
		mySize = indexCount;
		buffer = Sys.gl.createBuffer();
		data = new Array<Int>();
		data[indexCount - 1] = 0;
	}
	
	public function lock(): Array<Int> {
		return data;
	}
	
	public function unlock(): Void {
		Sys.gl.bindBuffer(Sys.gl.ELEMENT_ARRAY_BUFFER, buffer);
		Sys.gl.bufferData(Sys.gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(data), usage == Usage.DynamicUsage ? Sys.gl.DYNAMIC_DRAW : Sys.gl.STATIC_DRAW);
	}
	
	public function set(): Void {
		Sys.gl.bindBuffer(Sys.gl.ELEMENT_ARRAY_BUFFER, buffer);
	}
	
	public function count(): Int {
		return mySize;
	}
}
