package kha.graphics4;

class ShaderStorageBuffer {
	var data: Array<Int>;
	var myCount: Int;

	public function new(indexCount: Int, type: VertexData) {
		myCount = indexCount;
		data = new Array<Int>();
		data[myCount - 1] = 0;
	}

	public function delete(): Void {}

	public function lock(): Array<Int> {
		return data;
	}

	public function unlock(): Void {}

	public function count(): Int {
		return myCount;
	}
}
