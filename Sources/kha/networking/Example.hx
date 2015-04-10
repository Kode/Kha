package kha.networking;

class Example implements Entity {
	@replicated
	private var test: Float;
	@replicated
	private var bla: Int;

	public function new() {
		//super();
		test = 3;
	}
	
	public function id(): Int {
		return _id;
	}
	
	public function size(): Int {
		return _size;
	}
	
	public function simulate(tdif: Float): Void {
		
	}
}
