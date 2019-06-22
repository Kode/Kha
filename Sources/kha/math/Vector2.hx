package kha.math;

@:structInit
class Vector2 {
	public inline function new(x: Float = 0, y: Float = 0): Void {
		this.x = x;
		this.y = y;
	}

	public var x: Float;
	public var y: Float;
	public var length(get, set): Float;

	@:extern public inline function setFrom(v: Vector2): Void {
		this.x = v.x;
		this.y = v.y;
	}

	private inline function get_length(): Float {
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

	@:deprecated("normalize() will be deprecated soon, use the immutable normalized() instead")
	@:extern public inline function normalize(): Void {
		#if haxe4 inline #end set_length(1);
	}

	@:extern public inline function normalized(): Vector2 {
		var v = new Vector2(x, y);
		#if haxe4 inline #end v.set_length(1);
		return v;
	}

	@:extern public inline function angle(v: Vector2): Float {
		return Math.atan2(y,x) - Math.atan2(v.y,v.x);
	}

	@:extern public inline function fast(): FastVector2 {
		return new FastVector2(x, y);
	}
}
