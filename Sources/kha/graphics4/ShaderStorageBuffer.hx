package kha.graphics4;

extern class ShaderStorageBuffer {
	public function new(indexCount: Int, type: VertexData);
	public function delete(): Void;
	public function lock(): Array<Int>;
	public function unlock(): Void;
	public function set(): Void;
	public function count(): Int;
}
