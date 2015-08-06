package kha.math;

class FastVector2 {
	public inline function new(x: FastFloat = 0, y: FastFloat = 0): Void {
		this.x = x;
		this.y = y;
	}
	
	public var x: FastFloat;
	public var y: FastFloat;
	public var length(get, set): FastFloat;
	
	private function get_length(): FastFloat {
		return Math.sqrt(x * x + y * y);
	}
	
	private function set_length(length: FastFloat): FastFloat {
		if (get_length() == 0) return 0;
		var mul = length / get_length();
		x *= mul;
		y *= mul;
		return length;
	}
	
	@:extern public inline function add(vec: FastVector2): FastVector2 {
		return new FastVector2(x + vec.x, y + vec.y);
	}
	
	@:extern public inline function sub(vec: FastVector2): FastVector2 {
		return new FastVector2(x - vec.x, y - vec.y);
	}
	
	@:extern public inline function mult(value: FastFloat): FastVector2 {
		return new FastVector2(x * value, y * value);
	}
	
	@:extern public inline function div(value: FastFloat): FastVector2 {
		return mult(1 / value);
	}
	
	@:extern public inline function dot(v: FastVector2): FastFloat {
		return x * v.x + y * v.y;
	}
	
	@:extern public inline function normalize(): Void {
		var l = 1 / length;
		x *= l;
		y *= l;
	}
}
