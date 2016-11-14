package kha.graphics4;

import kha.graphics4.Usage;

class IndexBuffer {
	private var data: Array<Int>;
	private var mySize: Int;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		mySize = indexCount;
		data = new Array<Int>();
		data[indexCount - 1] = 0;
	}
	
	public function delete(): Void {
		data = null;
	}
	
	public function lock(): Array<Int> {
		return data;
	}
	
	public function unlock(): Void {

	}
	
	public function set(): Void {
		
	}
	
	public function count(): Int {
		return mySize;
	}
}
