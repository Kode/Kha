package kha.graphics2.truetype;

class BakedChar {
	public function new() {
		X0 = 0;
		Y0 = 0;
		X1 = 0;
		Y1 = 0;
		XOffset = 0;
		YOffset = 0;
		XAdvance = 0;
	}

	public static var Empty(get, null): BakedChar;
	
	private static function get_Empty(): BakedChar {
		return new BakedChar();
	}

	
	public var X0: Int;
	public var Y0: Int;
	public var X1: Int;
	public var Y1: Int;
	
	public var XOffset: Float;
	public var YOffset: Float;
	public var XAdvance: Float;

	public function GetBakedQuad(bakeWidth: Int, bakeHeight: Int, xPosition: { value: Float }, yPosition: { value: Float }, putTexCoordsAtTexelCenters: Bool = false): BakedQuad {
		var quad = new BakedQuad();
		//stb_truetype.stbtt_GetBakedQuad(this, bakeWidth, bakeHeight, { value: xPosition }, { value: yPosition }, quad, putTexCoordsAtTexelCenters ? 0 : 1); // TODO
		return quad;
	}
	
	public var IsEmpty(get, null): Bool;

	private function get_IsEmpty(): Bool {
		return Width == 0 && Height == 0 && XAdvance == 0;
	}
	
	public var Width(get, null): Int;

	private function get_Width(): Int {
		return X1 - X0;
	}
	
	public var Height(get, null): Int;

	private function get_Height(): Int {
		return Y1 - Y0;
	}
}
