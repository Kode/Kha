package kha.math;

@:structInit
class FastVector2 {
	public inline function new(x: FastFloat = 0, y: FastFloat = 0): Void {
		this.x = x;
		this.y = y;
	}

	public static function fromVector2(v: Vector2): FastVector2 {
		return new FastVector2(v.x, v.y);
	}

	public var x: FastFloat;
	public var y: FastFloat;
	public var length(get, set): FastFloat;

	@:extern public inline function setFrom(v: FastVector2): Void {
		this.x = v.x;
		this.y = v.y;
	}

	inline function get_length(): FastFloat {
		return Math.sqrt(x * x + y * y);
	}

	inline function set_length(length: FastFloat): FastFloat {
		var currentLength = get_length();
		if (currentLength == 0)
			return 0;
		var mul = length / currentLength;
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

	@:deprecated("normalize() will be deprecated soon, use the immutable normalized() instead")
	@:extern public inline function normalize(): Void {
		#if haxe4 inline #end set_length(1);
	}

	@:extern public inline function normalized(): FastVector2 {
		var v = new FastVector2(x, y);
		#if haxe4 inline #end v.set_length(1);
		return v;
	}

	@:extern public inline function angle(v: FastVector2): FastFloat {
		return Math.atan2(x * v.y - y * v.x, x * v.x + y * v.y);
	}

	public function toString() {
		return 'FastVector2($x, $y)';
	}
}
