package kha.graphics4;

import kha.arrays.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class VertexBuffer {
	private var buffer: Dynamic;
	private var data: Float32Array;
	private var mySize: Int;
	private var myStride: Int;
	private var sizes: Array<Int>;
	private var offsets: Array<Int>;
	private var usage: Usage;
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		mySize = vertexCount;
		myStride = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case VertexData.Float1:
				myStride += 4 * 1;
			case VertexData.Float2:
				myStride += 4 * 2;
			case VertexData.Float3:
				myStride += 4 * 3;
			case VertexData.Float4:
				myStride += 4 * 4;
			}
		}
	
		buffer = Sys.gl.createBuffer();
		data = new Float32Array(Std.int(vertexCount * myStride / 4));
		
		sizes = new Array<Int>();
		offsets = new Array<Int>();
		sizes[structure.elements.length - 1] = 0;
		offsets[structure.elements.length - 1] = 0;
		
		var offset = 0;
		var index = 0;
		for (element in structure.elements) {
			var size;
			switch (element.data) {
			case VertexData.Float1:
				size = 1;
			case VertexData.Float2:
				size = 2;
			case VertexData.Float3:
				size = 3;
			case VertexData.Float4:
				size = 4;
			}
			sizes[index] = size;
			offsets[index] = offset;
			switch (element.data) {
			case VertexData.Float1:
				offset += 4 * 1;
			case VertexData.Float2:
				offset += 4 * 2;
			case VertexData.Float3:
				offset += 4 * 3;
			case VertexData.Float4:
				offset += 4 * 4;
			}
			++index;
		}
	}
	
	public function lock(?start: Int, ?count: Int): Float32Array {
		return data;
	}
	
	public function unlock(): Void {
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
		Sys.gl.bufferData(Sys.gl.ARRAY_BUFFER, data, usage == Usage.DynamicUsage ? Sys.gl.DYNAMIC_DRAW : Sys.gl.STATIC_DRAW);
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function count(): Int {
		return mySize;
	}
	
	public function set(): Void {
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
		for (i in 0...sizes.length) {
			Sys.gl.enableVertexAttribArray(i);
			Sys.gl.vertexAttribPointer(i, sizes[i], Sys.gl.FLOAT, false, myStride, offsets[i]);
		}
	}
}
