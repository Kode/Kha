package kha.js.graphics;

import kha.graphics.VertexStructure;
import kha.graphics.VertexData;

class VertexBuffer implements kha.graphics.VertexBuffer {
	private var buffer: Dynamic;
	private var data: Array<Float>;
	private var mySize: Int;
	private var myStride: Int;
	private var myStructure: VertexStructure;
	
	public function new(vertexCount: Int, structure: VertexStructure) {
		mySize = vertexCount;
		myStride = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case VertexData.Float2:
				myStride += 4 * 2;
			case VertexData.Float3:
				myStride += 4 * 3;
			}
		}
		myStructure = structure;
		buffer = Sys.gl.createBuffer();
		data = new Array<Float>();
		data[Std.int(vertexCount * myStride / 4) - 1] = 0;
		
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
		var stride = 0;
		for (element in myStructure.elements) {
			switch (element.data) {
			case VertexData.Float2:
				stride += 4 * 2;
			case VertexData.Float3:
				stride += 4 * 3;
			}
		}
		var offset = 0;
		var index = 0;
		for (element in myStructure.elements) {
			Sys.gl.enableVertexAttribArray(index);
			var size;
			switch (element.data) {
			case VertexData.Float2:
				size = 2;
			case VertexData.Float3:
				size = 3;
			}
			Sys.gl.vertexAttribPointer(index, size, Sys.gl.FLOAT, false, stride, offset);
			switch (element.data) {
			case VertexData.Float2:
				offset += 4 * 2;
			case VertexData.Float3:
				offset += 4 * 3;
			}
			++index;
		}
	}
	
	public function lock(?start: Int, ?count: Int): Array<Float> {
		return data;
	}
	
	public function unlock(): Void {
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
		Sys.gl.bufferData(Sys.gl.ARRAY_BUFFER, new Float32Array(data), Sys.gl.STATIC_DRAW);
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function size(): Int {
		return mySize;
	}
	
	public function set(): Void {
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
	}
}
