package kha.network;

class Example implements Entity {
	@replicated
	private var test: Float;
	@replicated
	private var bla: Int;

	public function new() {
		//super();
		test = 3;
	}
	
	public function simulate(tdif: Float): Void {
		
	}
}
