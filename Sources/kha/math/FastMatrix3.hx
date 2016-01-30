package kha.math;

class FastMatrix3 {
	private static inline var width: Int = 3;
	private static inline var height: Int = 3;

	public var _00: FastFloat; public var _10: FastFloat; public var _20: FastFloat;
	public var _01: FastFloat; public var _11: FastFloat; public var _21: FastFloat;
	public var _02: FastFloat; public var _12: FastFloat; public var _22: FastFloat;

	public inline function new(_00: FastFloat, _10: FastFloat, _20: FastFloat,
								_01: FastFloat, _11: FastFloat, _21: FastFloat,
								_02: FastFloat, _12: FastFloat, _22: FastFloat) {
		this._00 = _00; this._10 = _10; this._20 = _20;
		this._01 = _01; this._11 = _11; this._21 = _21;
		this._02 = _02; this._12 = _12; this._22 = _22;
	}
	
	public static function fromMatrix3(m: Matrix3): FastMatrix3 {
		return new FastMatrix3(m._00, m._10, m._20,
								m._01, m._11, m._21,
								m._02, m._12, m._22);
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

	@:extern public static inline function translation(x: FastFloat, y: FastFloat): FastMatrix3 {
		return new FastMatrix3(
			1, 0, x,
			0, 1, y,
			0, 0, 1
		);
	}

	@:extern public static inline function empty(): FastMatrix3 {
		return new FastMatrix3(
			0, 0, 0,
			0, 0, 0,
			0, 0, 0
		);
	}

	@:extern public static inline function identity(): FastMatrix3 {
		return new FastMatrix3(
			1, 0, 0,
			0, 1, 0,
			0, 0, 1
		);
	}

	@:extern public static inline function scale(x: FastFloat, y: FastFloat): FastMatrix3 {
		return new FastMatrix3(
			x, 0, 0,
			0, y, 0,
			0, 0, 1
		);
	}

	@:extern public static inline function rotation(alpha: FastFloat): FastMatrix3 {
		return new FastMatrix3(
			Math.cos(alpha), -Math.sin(alpha), 0,
			Math.sin(alpha), Math.cos(alpha), 0,
			0, 0, 1
		);
	}

	@:extern public inline function add(m: FastMatrix3): FastMatrix3 {
		return new FastMatrix3(
			_00 + m._00, _10 + m._10, _20 + m._20,
			_01 + m._01, _11 + m._11, _21 + m._21,
			_02 + m._02, _12 + m._12, _22 + m._22
		);
	}

	@:extern public inline function sub(m: FastMatrix3): FastMatrix3 {
		return new FastMatrix3(
			_00 - m._00, _10 - m._10, _20 - m._20,
			_01 - m._01, _11 - m._11, _21 - m._21,
			_02 - m._02, _12 - m._12, _22 - m._22
		);
	}

	@:extern public inline function mult(value: FastFloat): FastMatrix3 {
		return new FastMatrix3(
			_00 * value, _10 * value, _20 * value,
			_01 * value, _11 * value, _21 * value,
			_02 * value, _12 * value, _22 * value
		);
	}

	@:extern public inline function transpose(): FastMatrix3 {
		return new FastMatrix3(
			_00, _01, _02,
			_10, _11, _12,
			_20, _21, _22
		);
	}

	@:extern public inline function trace(): FastFloat {
		return _00 + _11 + _22;
	}

	@:extern public inline function multmat(m: FastMatrix3): FastMatrix3 {
		return new FastMatrix3(
			_00 * m._00 + _10 * m._01 + _20 * m._02, _00 * m._10 + _10 * m._11 + _20 * m._12, _00 * m._20 + _10 * m._21 + _20 * m._22,
			_01 * m._00 + _11 * m._01 + _21 * m._02, _01 * m._10 + _11 * m._11 + _21 * m._12, _01 * m._20 + _11 * m._21 + _21 * m._22,
			_02 * m._00 + _12 * m._01 + _22 * m._02, _02 * m._10 + _12 * m._11 + _22 * m._12, _02 * m._20 + _12 * m._21 + _22 * m._22
		);
	}

	@:extern public inline function multvec(value: FastVector2): FastVector2 {
		//var product = new Vector2(0, 0);
		var w = _02 * value.x + _12 * value.y + _22 * 1;
		var x = (_00 * value.x + _10 * value.y + _20 * 1) / w;
		var y = (_01 * value.x + _11 * value.y + _21 * 1) / w;
		return new FastVector2(x, y);
	}

	@:extern public inline function cofactor(m0: FastFloat, m1: FastFloat, m2: FastFloat, m3: FastFloat): Float {
		return m0 * m3 - m1 * m2;
	}

    @:extern public inline function determinant(): FastFloat {
        var c00 = cofactor(_11, _21, _12, _22);
        var c01 = cofactor(_10, _20, _12, _22);
        var c02 = cofactor(_10, _20, _11, _21);
        return _00 * c00 - _01 * c01 + _02 * c02;
    }

    @:extern public inline function inverse(): FastMatrix3 {
		var c00 = cofactor(_11, _21, _12, _22);
		var c01 = cofactor(_10, _20, _12, _22);
		var c02 = cofactor(_10, _20, _11, _21);

		var det: FastFloat = _00 * c00 - _01 * c01 + _02 * c02;
		if (Math.abs(det) < 0.000001) {
			throw "determinant is too small";
		}
		
		var c10 = cofactor(_01, _21, _02, _22);
		var c11 = cofactor(_00, _20, _02, _22);
		var c12 = cofactor(_00, _20, _01, _21);

		var c20 = cofactor(_01, _11, _02, _12);
		var c21 = cofactor(_00, _10, _02, _12);
		var c22 = cofactor(_00, _10, _01, _11);

		var invdet: FastFloat = 1.0 / det;
		return new FastMatrix3(
			 c00 * invdet, -c01 * invdet,  c02 * invdet,
			-c10 * invdet,  c11 * invdet, -c12 * invdet,
			 c20 * invdet, -c21 * invdet,  c22 * invdet
		);
	}
}
