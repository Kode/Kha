package kha.graphics5;

import kha.arrays.Uint32Array;

class IndexBuffer {
	private var data: Uint32Array;
	private var myCount: Int;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		myCount = indexCount;
		data = new Uint32Array();
	}
	
	public function delete(): Void {
		
	}
	
	private function lock2(start: Int, count: Int): Uint32Array {
		return data;
	}

	public function lock(?start: Int, ?count: Int): Uint32Array {
		if (start == null) start = 0;
		if (count == null) count = this.count();
		return lock2(start, count);
	}
	
	public function unlock(): Void {
		
	}
	
	public function count(): Int {
		return myCount;
	}
}
