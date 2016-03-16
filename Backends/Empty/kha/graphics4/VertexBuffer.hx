package kha.graphics4;

import kha.arrays.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class VertexBuffer {
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {

	}
	
	public function lock(?start: Int, ?count: Int): Float32Array {
		return null;
	}
	
	public function unlock(): Void {
		
	}
	
	public function stride(): Int {
		return 0;
	}
	
	public function count(): Int {
		return 0;
	}
	
	public function set(offset: Int): Int {
		return 0;
	}
}
