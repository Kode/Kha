package kha.graphics4;

import kha.arrays.Float32Array;

extern class VertexBuffer {
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false);
	public function lock(?start: Int, ?count: Int): Float32Array;
	public function unlock(): Void;
	public function count(): Int;
	public function stride(): Int;
}
