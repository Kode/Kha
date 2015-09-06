package kha.math;

class Vector4 {
	public inline function new(x: Float = 0, y: Float = 0, z: Float = 0, w: Float = 1): Void {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	public var x: Float;
	public var y: Float;
	public var z: Float;
	public var w: Float;
	public var length(get, set): Float;
	
	private function get_length(): Float {
		return Math.sqrt(x * x + y * y + z * z + w * w);
	}
	
	private function set_length(length: Float): Float {
		var currentLength = get_length();
		if (currentLength == 0) return 0;
		var mul = length / currentLength;
		x *= mul;
		y *= mul;
		z *= mul;
		w *= mul;
		return length;
	}
	
	@:extern public inline function add(vec: Vector4): Vector4 {
		return new Vector4(x + vec.x, y + vec.y, z + vec.z, w + vec.w);
	}
	
	@:extern public inline function sub(vec: Vector4): Vector4 {
		return new Vector4(x - vec.x, y - vec.y, z - vec.z, w - vec.w);
	}
	
	@:extern public inline function mult(value: Float): Vector4 {
		return new Vector4(x * value, y * value, z * value, w * value);
	}
	
	@:extern public inline function normalize(): Void {
		length = 1;
	}
}
