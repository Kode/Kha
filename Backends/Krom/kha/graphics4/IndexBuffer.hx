package kha.graphics4;

import kha.graphics4.Usage;

class IndexBuffer {
	private var indexCount: Int;
	private var indices: Array<Int>;
	private var buffer: Dynamic;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.indexCount = indexCount;
		indices = [];
		buffer = Krom.createIndexBuffer(indexCount);
	}
	
	public function lock(): Array<Int> {
		return indices;
	}
	
	public function unlock(): Void {
		Krom.setIndices(buffer, indices);
	}
	
	public function set(): Void {
		Krom.setIndexBuffer(buffer);
	}
	
	public function count(): Int {
		return 0;
	}
}
