package kha.graphics2.truetype;

class BakedQuad {
	public function new() {
		X0 = 0;
		Y0 = 0;
		S0 = 0;
		T0 = 0;
		X1 = 0;
		Y1 = 0;
		S1 = 0;
		T1 = 0;
	}

	public static var Empty(get, null): BakedQuad;
	
	private static function get_Empty(): BakedQuad {
		return new BakedQuad();
	}

	public var X0: Float;
	public var Y0: Float;
	public var S0: Float;
	public var T0: Float;

	public var X1: Float;
	public var Y1: Float;
	public var S1: Float;
	public var T1: Float;

	public var IsEmpty(get, null): Bool;
	
	private function get_IsEmpty(): Bool {
		return X0 == X1 && Y0 == Y1;
	}
}
