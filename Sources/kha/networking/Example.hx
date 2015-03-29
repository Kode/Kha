package kha.networking;

class Example implements Entity {
	@replicated
	private var test: Float;

	public function new() {
		//super();
		test = 3;
	}
	
	public function id(): Int {
		return _id;
	}
	
	public function simulate(tdif: Float): Void {
		
	}
}
