package kha.graphics4;

class IndexBuffer {
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {}

	public function lock(?start: Int, ?count: Int): Array<Int> {
		return null;
	}

	public function unlock(?count: Int): Void {}

	public function set(): Void {}

	public function count(): Int {
		return 0;
	}
}
