package kha.math;

class Matrix2 {
	private static inline var width: Int = 2;
	private static inline var height: Int = 2;

	public var _00: Float; public var _10: Float;
	public var _01: Float; public var _11: Float;

	public inline function new(_00: Float, _10: Float,
								_01: Float, _11: Float) {
		this._00 = _00; this._10 = _10;
		this._01 = _01; this._11 = _11;
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

	@:extern public static inline function empty(): Matrix2 {
		return new Matrix2(
			0, 0,
			0, 0
		);
	}

	@:extern public static inline function identity(): Matrix2 {
		return new Matrix2(
			1, 0,
			0, 1
		);
	}

	@:extern public static inline function scale(x: Float, y: Float): Matrix2 {
		return new Matrix2(
			x, 0,
			0, y
		);
	}

	@:extern public static inline function rotation(alpha: Float): Matrix2 {
		return new Matrix2(
			Math.cos(alpha), -Math.sin(alpha),
			Math.sin(alpha), Math.cos(alpha)
		);
	}

	@:extern public inline function add(m: Matrix2): Matrix2 {
		return new Matrix2(
			_00 + m._00, _10 + m._10,
			_01 + m._01, _11 + m._11
		);
	}

	@:extern public inline function sub(m: Matrix2): Matrix2 {
		return new Matrix2(
			_00 - m._00, _10 - m._10,
			_01 - m._01, _11 - m._11
		);
	}

	@:extern public inline function mult(value: Float): Matrix2 {
		return new Matrix2(
			_00 * value, _10 * value,
			_01 * value, _11 * value
		);
	}

	@:extern public inline function transpose(): Matrix2 {
		return new Matrix2(
			_00, _01,
			_10, _11
		);
	}

	@:extern public inline function trace(): Float {
		return _00 + _11;
	}

	@:extern public inline function multmat(m: Matrix2): Matrix2 {
		return new Matrix2(
			_00 * m._00 + _10 * m._01, _00 * m._10 + _10 * m._11,
			_01 * m._00 + _11 * m._01, _01 * m._10 + _11 * m._11
		);
	}

	@:extern public inline function multvec(value: Vector2): Vector2 {
		var x = _00 * value.x + _10 * value.y;
		var y = _01 * value.x + _11 * value.y;
		return new Vector2(x, y);
	}
}
