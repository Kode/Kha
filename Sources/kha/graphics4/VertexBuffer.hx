package kha.graphics4;

extern class VertexBuffer {
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false);
	public function lock(?start: Int, ?count: Int): Array<Float>;
	public function unlock(): Void;
	public function count(): Int;
	public function stride(): Int;
}
