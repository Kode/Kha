package kha.math;

class Vector3 {
	public inline function new(x: Float = 0, y: Float = 0, z: Float = 0): Void {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public var x: Float;
	public var y: Float;
	public var z: Float;
	public var length(get, set): Float;
	
	private function get_length(): Float {
		return Math.sqrt(x * x + y * y + z * z);
	}
	
	private function set_length(length: Float): Float {
		var currentLength = get_length();
		if (currentLength == 0) return 0;
		var mul = length / currentLength;
		x *= mul;
		y *= mul;
		z *= mul;
		return length;
	}
	
	@:extern public inline function add(vec: Vector3): Vector3 {
		return new Vector3(x + vec.x, y + vec.y, z + vec.z);
	}
	
	@:extern public inline function sub(vec: Vector3): Vector3 {
		return new Vector3(x - vec.x, y - vec.y, z - vec.z);
	}
	
	@:extern public inline function mult(value: Float): Vector3 {
		return new Vector3(x * value, y * value, z * value);
	}
	
	@:extern public inline function dot(v: Vector3): Float {
		return x * v.x + y * v.y + z * v.z;
	}
	
	@:extern public inline function cross(v: Vector3): Vector3 {
		var _x = y * v.z - z * v.y;
		var _y = z * v.x - x * v.z;
		var _z = x * v.y - y * v.x;
		return new Vector3(_x, _y, _z);
	}
	
	@:extern public inline function normalize(): Void {
		length = 1;
	}
}
