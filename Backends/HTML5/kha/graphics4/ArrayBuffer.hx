package kha.graphics4;

import haxe.io.Float32Array;
import kha.graphics4.Usage;

class ArrayBuffer {
	private var buffer: Dynamic;
	private var data: Float32Array;
	private var mySize: Int;
	private var structureSize: Int;
	private var usage: Usage;
	
	public function new(indexCount: Int, structureSize: Int, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		this.structureSize = structureSize;
		mySize = indexCount;
		buffer = Sys.gl.createBuffer();
		data = new Float32Array(indexCount);
		data[indexCount - 1] = 0;
	}
	
	public function lock(): Float32Array {
		return data;
	}
	
	public function unlock(): Void {
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
		Sys.gl.bufferData(Sys.gl.ARRAY_BUFFER, data, usage == Usage.DynamicUsage ? Sys.gl.DYNAMIC_DRAW : Sys.gl.STATIC_DRAW);
	}
	
	public function set(location : AttributeLocation): Void {
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
		Sys.gl.enableVertexAttribArray(cast(location, kha.js.graphics4.AttributeLocation).value);
		Sys.gl.vertexAttribPointer(cast(location, kha.js.graphics4.AttributeLocation).value, structureSize, Sys.gl.FLOAT, false, 0, 0);
	}
	
	public function count(): Int {
		return mySize;
	}
}
