package kha.graphics4;

class IndexBuffer {
	private var indices: Array<Int>;
	private var indexCount: Int;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.indexCount = indexCount;
		indices = new Array<Int>();
	}

	public function lock(): Array<Int> {
		return indices;
	}

	public function unlock(): Void {
		
	}

	public function set(): Void {
		
	}

	public function count(): Int {
		return indexCount;
	}
}
