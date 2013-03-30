package kha.js.graphics;

class IndexBuffer implements kha.graphics.IndexBuffer{
	private var data: Array<Int>;
	
	public function new(indexCount: Int) {
		data = new Array<Int>();
		data[indexCount - 1] = 0;
	}
	
	public function lock(): Array<Int> {
		return data;
	}
	
	public function unlock(): Void {
		
	}
	
	public function set(): Void {
		
	}
}