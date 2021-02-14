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
			switch (element.data) {
				case Float1:
					myStride += 4 * 1;
				case Float2:
					myStride += 4 * 2;
				case Float3:
					myStride += 4 * 3;
				case Float4:
					myStride += 4 * 4;
				case Float4x4:
					myStride += 4 * 4 * 4;
				case Short2Norm:
					myStride += 2 * 2;
				case Short4Norm:
					myStride += 2 * 4;
			}
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
