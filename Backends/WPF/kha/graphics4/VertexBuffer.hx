package kha.graphics4;

class VertexBuffer {
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false) { }
	public function lock(?start: Int, ?count: Int): Array<Float> { return null; }
	public function unlock(): Void { }
	public function count(): Int { return 0; }
	public function stride(): Int { return 1; }
}
