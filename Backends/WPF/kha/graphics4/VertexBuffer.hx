package kha.graphics4;
import haxe.io.Float32Array;
class VertexBuffer {
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false) { }
	public function lock(?start: Int, ?count: Int): Float32Array { return null; }
	public function unlock(): Void { }
	public function count(): Int { return 0; }
	public function stride(): Int { return 1; }
}
