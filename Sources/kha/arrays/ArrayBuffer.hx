package kha.arrays;

class ArrayBuffer {
	private var length: Int;
	
	public function new(length: Int) {
		this.length = length;
	}
	
	public var byteLength(get, null);
	
	private function get_byteLength(): Int {
		return length;
	}
}
