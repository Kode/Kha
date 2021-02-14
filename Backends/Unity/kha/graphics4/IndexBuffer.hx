package kha.graphics4;

import cs.NativeArray;

class IndexBuffer {
	public var nativeIndices: NativeArray<Int>;
	public var nativeCutIndices: NativeArray<Int>;

	var indices: Array<Int>;
	var indexCount: Int;

	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.indexCount = indexCount;
		indices = new Array<Int>();
		nativeIndices = new NativeArray<Int>(indexCount);
		nativeCutIndices = new NativeArray<Int>(indexCount);
	}

	public function lock(?start: Int, ?count: Int): Array<Int> {
		return indices;
	}

	public function unlock(?count: Int): Void {
		for (i in 0...indexCount) {
			nativeIndices[i] = indices[i];
		}
	}

	public function set(): Void {}

	public function count(): Int {
		return indexCount;
	}
}
