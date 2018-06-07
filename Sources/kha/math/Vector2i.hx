package kha.math;

@:structInit
class Vector2i {
	public inline function new(x: Int = 0, y: Int = 0): Void {
		this.x = x;
		this.y = y;
	}
	
	public var x: Int;
	public var y: Int;

	@:extern public inline function setFrom(v: Vector2i): Void {
		this.x = v.x;
		this.y = v.y;
	}
	
	@:extern public inline function add(vec: Vector2i): Vector2i {
		return new Vector2i(x + vec.x, y + vec.y);
	}
	
	@:extern public inline function sub(vec: Vector2i): Vector2i {
		return new Vector2i(x - vec.x, y - vec.y);
	}
	
	@:extern public inline function mult(value: Int): Vector2i {
		return new Vector2i(x * value, y * value);
	}
	
	@:extern public inline function div(value: Int): Vector2i {
		return new Vector2i(Std.int(x / value), Std.int(y / value));
	}
	
	@:extern public inline function dot(v: Vector2i): Float {
		return x * v.x + y * v.y;
	}
}
