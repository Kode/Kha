package kha.graphics4;

import js.html.webgl.GL;
import kha.arrays.Uint32Array;
import kha.graphics4.Usage;

class IndexBuffer {
	public var _data: Uint32Array;

	var buffer: Dynamic;
	var mySize: Int;
	var usage: Usage;
	var lockStart: Int = 0;
	var lockEnd: Int = 0;

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
		lockStart = start != null ? start : 0;
		lockEnd = count != null ? start + count : mySize;
		return _data.subarray(lockStart, lockEnd);
	}

	public function unlock(?count: Int): Void {
		if (count != null)
			lockEnd = lockStart + count;
		SystemImpl.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		var data = _data.subarray(lockStart, lockEnd);
		var glData: Dynamic = SystemImpl.elementIndexUint == null ? new js.lib.Uint16Array(data.buffer) : data;
		SystemImpl.gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, glData, usage == Usage.DynamicUsage ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
	}

	public function set(): Void {
		SystemImpl.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
	}

	public function count(): Int {
		return mySize;
	}
}
