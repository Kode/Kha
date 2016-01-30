package kha.math;

class FastVector3 {
	public inline function new(x: FastFloat = 0, y: FastFloat = 0, z: FastFloat = 0): Void {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public static function fromVector3(v: Vector3): FastVector3 {
		return new FastVector3(v.x, v.y, v.z);
	}
	
	public var x: FastFloat;
	public var y: FastFloat;
	public var z: FastFloat;
	public var length(get, set): FastFloat;
	
	private function get_length(): FastFloat {
		return Math.sqrt(x * x + y * y + z * z);
	}
	
	private function set_length(length: FastFloat): FastFloat {
		var currentLength = get_length();
		if (currentLength == 0) return 0;
		var mul = length / currentLength;
		x *= mul;
		y *= mul;
		z *= mul;
		return length;
	}
	
	@:extern public inline function add(vec: FastVector3): FastVector3 {
		return new FastVector3(x + vec.x, y + vec.y, z + vec.z);
	}
	
	@:extern public inline function sub(vec: FastVector3): FastVector3 {
		return new FastVector3(x - vec.x, y - vec.y, z - vec.z);
	}
	
	@:extern public inline function mult(value: FastFloat): FastVector3 {
		return new FastVector3(x * value, y * value, z * value);
	}
	
	@:extern public inline function dot(v: FastVector3): FastFloat {
		return x * v.x + y * v.y + z * v.z;
	}
	
	@:extern public inline function cross(v: FastVector3): FastVector3 {
		var _x = y * v.z - z * v.y;
		var _y = z * v.x - x * v.z;
		var _z = x * v.y - y * v.x;
		return new FastVector3(_x, _y, _z);
	}
	
	@:extern public inline function normalize(): Void {
		length = 1;
	}
}
