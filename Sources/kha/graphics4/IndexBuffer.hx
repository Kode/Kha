package kha.graphics4;

extern class IndexBuffer {
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false);
	public function delete(): Void;
	public function lock(): Array<Int>;
	public function unlock(): Void;
	public function set(): Void;
	public function count(): Int;
}
