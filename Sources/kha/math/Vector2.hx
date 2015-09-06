package kha.math;

class Vector2 {
	public inline function new(x: Float = 0, y: Float = 0): Void {
		this.x = x;
		this.y = y;
	}
	
	public var x: Float;
	public var y: Float;
	public var length(get, set): Float;
	
	private function get_length(): Float {
		return Math.sqrt(x * x + y * y);
	}
	
	private function set_length(length: Float): Float {
		var currentLength = get_length();
		if (currentLength == 0) return 0;
		var mul = length / currentLength;
		x *= mul;
		y *= mul;
		return length;
	}
	
	@:extern public inline function add(vec: Vector2): Vector2 {
		return new Vector2(x + vec.x, y + vec.y);
	}
	
	@:extern public inline function sub(vec: Vector2): Vector2 {
		return new Vector2(x - vec.x, y - vec.y);
	}
	
	@:extern public inline function mult(value: Float): Vector2 {
		return new Vector2(x * value, y * value);
	}
	
	@:extern public inline function div(value: Float): Vector2 {
		return mult(1 / value);
	}
	
	@:extern public inline function dot(v: Vector2): Float {
		return x * v.x + y * v.y;
	}
	
	@:extern public inline function normalize(): Void {
		length = 1;
	}
}
