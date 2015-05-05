package kha.graphics4;

import cs.NativeArray;
import cs.types.UInt16;
import kha.graphics4.Usage;

class IndexBuffer {
	public var buffer: NativeArray<UInt16>;
	private var indices: Array<Int>;
	private var indexCount: Int;
	
	public function new(indexCount: Int, usage: Usage) {
		this.indexCount = indexCount;
		indices = new Array<Int>();
		indices[indexCount - 1] = 0;
		buffer = new NativeArray<UInt16>(indexCount);
	}
	
	public function lock(): Array<Int> {
		return indices;
	}
	
	public function unlock(): Void {
		for (i in 0...indexCount) {
			buffer[i] = cast indices[i];
		}
	}
	
	public function count(): Int {
		return indexCount;
	}
}
