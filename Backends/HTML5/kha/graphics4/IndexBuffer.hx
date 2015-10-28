package kha.graphics4;

import kha.graphics4.Usage;

class IndexBuffer {
	private var buffer: Dynamic;
	private var data: Array<Int>;
	private var mySize: Int;
	private var usage: Usage;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		mySize = indexCount;
		buffer = SystemImpl.gl.createBuffer();
		data = new Array<Int>();
		data[indexCount - 1] = 0;
	}
	
	public function lock(): Array<Int> {
		return data;
	}
	
	public function unlock(): Void {
		SystemImpl.gl.bindBuffer(SystemImpl.gl.ELEMENT_ARRAY_BUFFER, buffer);
		SystemImpl.gl.bufferData(SystemImpl.gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(data), usage == Usage.DynamicUsage ? SystemImpl.gl.DYNAMIC_DRAW : SystemImpl.gl.STATIC_DRAW);
	}
	
	public function set(): Void {
		SystemImpl.gl.bindBuffer(SystemImpl.gl.ELEMENT_ARRAY_BUFFER, buffer);
	}
	
	public function count(): Int {
		return mySize;
	}
}
