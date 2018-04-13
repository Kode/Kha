package kha.graphics4;

import kha.arrays.Uint32Array;
import kha.graphics4.Usage;

class IndexBuffer {
	private var buffer: Dynamic;
	public var _data: Uint32Array;
	private var indexCount: Int;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.indexCount = indexCount;
		buffer = Krom.createIndexBuffer(indexCount);
	}

	public function delete() {
		Krom.deleteIndexBuffer(buffer);
		buffer = null;
	}
	
	public function lock(?start: Int, ?count: Int): Uint32Array {
		_data = Krom.lockIndexBuffer(buffer);
		if (start == null) start = 0;
		if (count == null) count = indexCount;
		return _data.subarray(start, start + count);
	}
	
	public function unlock(): Void {
		Krom.unlockIndexBuffer(buffer);
	}
	
	public function set(): Void {
		Krom.setIndexBuffer(buffer);
	}
	
	public function count(): Int {
		return indexCount;
	}
}
