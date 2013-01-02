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
	
	public function add(vec: Vector2): Vector2 {
		return new Vector2(x + vec.x, y + vec.y);
	}
	
	public function sub(vec: Vector2): Vector2 {
		return new Vector2(x - vec.x, y - vec.y);
	}
	
	public function mult(value: Float): Vector2 {
		return new Vector2(x * value, y * value);
	}
	
	public function div(value: Float): Vector2 {
		return mult(1 / value);
	}
}