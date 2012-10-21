package kha;

class Vector2 {
	public function new(x: Float = 0, y: Float = 0): Void {
		this.x = x;
		this.y = y;
	}
	
	public var x: Float;
	public var y: Float;
	public var length(getLength, setLength): Float;
	
	private function getLength(): Float {
		return Math.sqrt(x * x + y * y);
	}
	
	private function setLength(length: Float): Float {
		if (getLength() == 0) return 0;
		var mul = length / getLength();
		x *= mul;
		y *= mul;
		return length;
	}
}