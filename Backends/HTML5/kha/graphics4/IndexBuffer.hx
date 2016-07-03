package kha.graphics4;

import js.html.webgl.GL;
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
	
	public function delete(): Void {
		data = null;
		SystemImpl.gl.deleteBuffer(buffer);
	}
	
	public function lock(): Array<Int> {
		return data;
	}
	
	public function unlock(): Void {
		SystemImpl.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		SystemImpl.gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, cast new Uint16Array(data), usage == Usage.DynamicUsage ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
	}
	
	public function set(): Void {
		SystemImpl.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
	}
	
	public function count(): Int {
		return mySize;
	}
}
