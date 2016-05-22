package kha.graphics4;

import kha.arrays.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class VertexBuffer {
	private var buffer: Dynamic;
	private var vertices: Float32Array;
	private var vertexCount: Int;
	private var structure: VertexStructure;
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		this.vertexCount = vertexCount;
		this.structure = structure;
		buffer = Krom.createVertexBuffer(vertexCount, structure.elements);
		vertices = new Float32Array(vertexCount * Std.int(structure.byteSize() / 4));
	}
	
	public function lock(?start: Int, ?count: Int): Float32Array {
		return vertices;
	}
	
	public function unlock(): Void {
		Krom.setVertices(buffer, vertices);
	}
	
	public function stride(): Int {
		return structure.byteSize();
	}
	
	public function count(): Int {
		return vertexCount;
	}
	
	public function set(offset: Int): Int {
		Krom.setVertexBuffer(buffer);
		return 0;
	}
}
