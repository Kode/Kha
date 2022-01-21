package kha.graphics4;

import kha.arrays.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class VertexBuffer {
	var data: Float32Array;
	var mySize: Int;
	var myStride: Int;

	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		mySize = vertexCount;
		myStride = 0;
		for (element in structure.elements) {
			myStride += VertexData.getStride(element.data);
		}

		data = new Float32Array(Std.int(vertexCount * myStride / 4));
	}

	public function delete(): Void {
		data = null;
	}

	public function lock(?start: Int, ?count: Int): Float32Array {
		return data;
	}

	public function unlock(?count: Int): Void {}

	public function stride(): Int {
		return myStride;
	}

	public function count(): Int {
		return mySize;
	}

	public function set(offset: Int): Int {
		return 0;
	}
}
