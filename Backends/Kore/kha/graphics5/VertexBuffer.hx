package kha.graphics5;

import kha.arrays.Float32Array;

class VertexBuffer {
	private var data: Float32Array;
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		init(vertexCount, structure, usage.getIndex(), instanceDataStepRate);
		data = new Float32Array();
	}
	
	public function delete(): Void {
		
	}
	
	private function init(vertexCount: Int, structure: VertexStructure, usage: Int, instanceDataStepRate: Int) {
		
	}

	private function lock2(start: Int, count: Int): Float32Array {
		return data;
	}

	public function lock(?start: Int, ?count: Int): Float32Array {
		if (start == null) start = 0;
		if (count == null) count = this.count();
		return lock2(start, count);
	}
	
	public function unlock(): Void {
		
	}
	
	public function stride(): Int {
		return 0;
	}
	
	public function count(): Int {
		return 0;
	}
}
