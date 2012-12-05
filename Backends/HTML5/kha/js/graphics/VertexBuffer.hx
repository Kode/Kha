package kha.js.graphics;

import kha.graphics.VertexStructure;

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
			switch (element.type) {
			case VertexData.Float2:
				myStride += 4 * 2;
			case VertexData.Float3:
				myStride += 4 * 3;
			}
		}
		myStructure = structure;
		buffer = Sys.gl.createBuffer();
		data = new Array<Float>();
		++vertexCount; //evil hack - browser stride bug?
		data[Std.int(vertexCount * myStride / 4) - 1] = 0;
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
	
	public function bind(program: Dynamic): Void {
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
		var offset = 0;
		for (element in myStructure.elements) {
			var attribute = Sys.gl.getAttribLocation(program, element.name);
			Sys.gl.enableVertexAttribArray(attribute);
			Sys.gl.vertexAttribPointer(attribute, mySize, Sys.gl.FLOAT, false, myStride, offset);
			switch (element.type) {
			case VertexData.Float2:
				offset += 4 * 2;
			case VertexData.Float3:
				offset += 4 * 3;
			}
		}
	}
}