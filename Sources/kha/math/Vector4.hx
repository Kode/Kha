package kha.math;

@:structInit
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

	@:extern public inline function setFrom(v: Vector4): Void {
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = v.w;
	}

	private inline function get_length(): Float {
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

	@:deprecated("normalize() will be deprecated soon, use the immutable normalized() instead")
	@:extern public inline function normalize(): Void {
		#if haxe4 inline #end set_length(1);
	}

	@:extern public inline function normalized(): Vector4 {
		var v = new Vector4(x, y, z, w);
		#if haxe4 inline #end v.set_length(1);
		return v;
	}

	@:extern public inline function fast(): FastVector4 {
		return new FastVector4(x, y, z, w);
	}
}
