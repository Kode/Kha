package kha.math;

class FastMatrix2 {
	static inline var width: Int = 2;
	static inline var height: Int = 2;

	public var _00: FastFloat;
	public var _10: FastFloat;
	public var _01: FastFloat;
	public var _11: FastFloat;

	public inline function new(_00: FastFloat, _10: FastFloat, _01: FastFloat, _11: FastFloat) {
		this._00 = _00;
		this._10 = _10;
		this._01 = _01;
		this._11 = _11;
	}

	/*@:arrayAccess public inline function get(index: Int): Float {
			return this[index];
		}

		@:arrayAccess public inline function set(index: Int, value: Float): Float {
			this[index] = value;
			return value;
		}

		public static function index(x: Int, y: Int): Int {
			return y * width + x;
	}*/
	@:extern public inline function setFrom(m: FastMatrix2): Void {
		this._00 = m._00;
		this._10 = m._10;
		this._01 = m._01;
		this._11 = m._11;
	}

	@:extern public static inline function empty(): FastMatrix2 {
		return new FastMatrix2(0, 0, 0, 0);
	}

	@:extern public static inline function identity(): FastMatrix2 {
		return new FastMatrix2(1, 0, 0, 1);
	}

	@:extern public static inline function scale(x: FastFloat, y: FastFloat): FastMatrix2 {
		return new FastMatrix2(x, 0, 0, y);
	}

	@:extern public static inline function rotation(alpha: FastFloat): FastMatrix2 {
		return new FastMatrix2(Math.cos(alpha), -Math.sin(alpha), Math.sin(alpha), Math.cos(alpha));
	}

	@:extern public inline function add(m: FastMatrix2): FastMatrix2 {
		return new FastMatrix2(_00 + m._00, _10 + m._10, _01 + m._01, _11 + m._11);
	}

	@:extern public inline function sub(m: FastMatrix2): FastMatrix2 {
		return new FastMatrix2(_00 - m._00, _10 - m._10, _01 - m._01, _11 - m._11);
	}

	@:extern public inline function mult(value: FastFloat): FastMatrix2 {
		return new FastMatrix2(_00 * value, _10 * value, _01 * value, _11 * value);
	}

	@:extern public inline function transpose(): FastMatrix2 {
		return new FastMatrix2(_00, _01, _10, _11);
	}

	@:extern public inline function trace(): FastFloat {
		return _00 + _11;
	}

	@:extern public inline function multmat(m: FastMatrix2): FastMatrix2 {
		return new FastMatrix2(_00 * m._00 + _10 * m._01, _00 * m._10 + _10 * m._11, _01 * m._00 + _11 * m._01, _01 * m._10 + _11 * m._11);
	}

	@:extern public inline function multvec(value: FastVector2): FastVector2 {
		var x = _00 * value.x + _10 * value.y;
		var y = _01 * value.x + _11 * value.y;
		return new FastVector2(x, y);
	}
}
