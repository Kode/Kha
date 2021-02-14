package kha.math;

@:structInit
class FastVector4 {
	public inline function new(x: FastFloat = 0, y: FastFloat = 0, z: FastFloat = 0, w: FastFloat = 1): Void {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	public static function fromVector4(v: Vector4): FastVector4 {
		return new FastVector4(v.x, v.y, v.z, v.w);
	}

	public var x: FastFloat;
	public var y: FastFloat;
	public var z: FastFloat;
	public var w: FastFloat;
	public var length(get, set): FastFloat;

	@:extern public inline function setFrom(v: FastVector4): Void {
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		this.w = v.w;
	}

	inline function get_length(): FastFloat {
		return Math.sqrt(x * x + y * y + z * z + w * w);
	}

	function set_length(length: FastFloat): FastFloat {
		var currentLength = get_length();
		if (currentLength == 0)
			return 0;
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

	@:deprecated("normalize() will be deprecated soon, use the immutable normalized() instead")
	@:extern public inline function normalize(): Void {
		#if haxe4 inline #end set_length(1);
	}

	@:extern public inline function normalized(): FastVector4 {
		var v = new FastVector4(x, y, z, w);
		#if haxe4 inline #end v.set_length(1);
		return v;
	}

	public function toString() {
		return 'FastVector4($x, $y, $z, $w)';
	}
}
