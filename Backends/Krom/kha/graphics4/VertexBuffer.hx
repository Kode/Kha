package kha.graphics4;

import kha.arrays.Float32Array;
import kha.arrays.Int16Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class VertexBuffer {
	public var buffer: Dynamic;
	public var _data: Float32Array;

	var vertexCount: Int;
	var structure: VertexStructure;
	var mySize: Int;
	var lockStart: Int = 0;
	var lockEnd: Int = 0;

	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		this.vertexCount = vertexCount;
		this.structure = structure;
		mySize = vertexCount;
		buffer = Krom.createVertexBuffer(vertexCount, structure.elements, usage, instanceDataStepRate);
	}

	public function delete() {
		Krom.deleteVertexBuffer(buffer);
		buffer = null;
	}

	public function lock(?start: Int, ?count: Int): Float32Array {
		lockStart = start != null ? start : 0;
		lockEnd = count != null ? start + count : mySize;
		_data = Krom.lockVertexBuffer(buffer, lockStart, lockEnd);
		return _data;
	}

	public function lockInt16(?start: Int, ?count: Int): Int16Array {
		return new Int16Array(untyped lock(start, count).buffer);
	}

	public function unlock(?count: Int): Void {
		if (count != null) {
			lockEnd = lockStart + count;
		}
		Krom.unlockVertexBuffer(buffer, lockEnd);
	}

	public function stride(): Int {
		return structure.byteSize();
	}

	public function count(): Int {
		return vertexCount;
	}

	public function set(offset: Int): Int {
		Krom.setVertexBuffer(buffer);
		return 0;
	}
}
