package kha.netsync;

class Example implements Entity {
	@replicated
	var test: Float;
	@replicated
	var bla: Int;

	public function new() {
		// super();
		test = 3;
	}

	public function simulate(tdif: Float): Void {}
}
