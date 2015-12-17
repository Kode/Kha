package kha.math;

class FastVector4 {
	public inline function new(x: FastFloat = 0, y: FastFloat = 0, z: FastFloat = 0, w: FastFloat = 1): Void {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	public var x: FastFloat;
	public var y: FastFloat;
	public var z: FastFloat;
	public var w: FastFloat;
	public var length(get, set): FastFloat;
	
	private function get_length(): FastFloat {
		return Math.sqrt(x * x + y * y + z * z + w * w);
	}
	
	private function set_length(length: FastFloat): FastFloat {
		var currentLength = get_length();
		if (currentLength == 0) return 0;
		var mul = length / currentLength;
		x *= mul;
		y *= mul;
		z *= mul;
		w *= mul;
		return length;
	}
	
	@:extern public inline function add(vec: FastVector4): FastVector4 {
		return new FastVector4(x + vec.x, y + vec.y, z + vec.z, w + vec.w);
	}
	
	@:extern public inline function sub(vec: FastVector4): FastVector4 {
		return new FastVector4(x - vec.x, y - vec.y, z - vec.z, w - vec.w);
	}
	
	@:extern public inline function mult(value: FastFloat): FastVector4 {
		return new FastVector4(x * value, y * value, z * value, w * value);
	}
	
	@:extern public inline function normalize(): Void {
		length = 1;
	}
}
