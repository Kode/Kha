package kha.graphics4;

import js.html.webgl.GL;
import kha.arrays.Uint32Array;
import kha.graphics4.Usage;

class IndexBuffer {
	private var buffer: Dynamic;
	public var _data: Uint32Array;
	private var mySize: Int;
	private var usage: Usage;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		mySize = indexCount;
		buffer = SystemImpl.gl.createBuffer();
		_data = new Uint32Array(indexCount);
	}
	
	public function delete(): Void {
		_data = null;
		SystemImpl.gl.deleteBuffer(buffer);
	}
	
	public function lock(?start: Int, ?count: Int): Uint32Array {
		return _data;
	}
	
	public function unlock(): Void {
		SystemImpl.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		var test = SystemImpl.elementIndexUint == null;
		var glData: Dynamic = _data.data(); // SystemImpl.elementIndexUint == null ? new Uint16Array(_data) : new js.html.Uint32Array(_data);
		SystemImpl.gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, glData, usage == Usage.DynamicUsage ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
	}
	
	public function set(): Void {
		SystemImpl.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
	}
	
	public function count(): Int {
		return mySize;
	}
}
