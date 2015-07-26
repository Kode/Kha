package kha.math;

class Matrix3 {
	private static inline var width: Int = 3;
	private static inline var height: Int = 3;

	public var _00: Float; public var _10: Float; public var _20: Float;
	public var _01: Float; public var _11: Float; public var _21: Float;
	public var _02: Float; public var _12: Float; public var _22: Float;

	public inline function new(_00: Float, _10: Float, _20: Float,
								_01: Float, _11: Float, _21: Float,
								_02: Float, _12: Float, _22: Float) {
		this._00 = _00; this._10 = _10; this._20 = _20;
		this._01 = _01; this._11 = _11; this._21 = _21;
		this._02 = _02; this._12 = _12; this._22 = _22;
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

	@:extern public static inline function translation(x: Float, y: Float): Matrix3 {
		return new Matrix3(
			1, 0, x,
			0, 1, y,
			0, 0, 1
		);
	}

	@:extern public static inline function empty(): Matrix3 {
		return new Matrix3(
			0, 0, 0,
			0, 0, 0,
			0, 0, 0
		);
	}

	@:extern public static inline function identity(): Matrix3 {
		return new Matrix3(
			1, 0, 0,
			0, 1, 0,
			0, 0, 1
		);
	}

	@:extern public static inline function scale(x: Float, y: Float): Matrix3 {
		return new Matrix3(
			x, 0, 0,
			0, y, 0,
			0, 0, 1
		);
	}

	@:extern public static inline function rotation(alpha: Float): Matrix3 {
		return new Matrix3(
			Math.cos(alpha), -Math.sin(alpha), 0,
			Math.sin(alpha), Math.cos(alpha), 0,
			0, 0, 1
		);
	}

	@:extern public inline function add(m: Matrix3): Matrix3 {
		return new Matrix3(
			_00 + m._00, _10 + m._10, _20 + m._20,
			_01 + m._01, _11 + m._11, _21 + m._21,
			_02 + m._02, _12 + m._12, _22 + m._22
		);
	}

	@:extern public inline function sub(m: Matrix3): Matrix3 {
		return new Matrix3(
			_00 - m._00, _10 - m._10, _20 - m._20,
			_01 - m._01, _11 - m._11, _21 - m._21,
			_02 - m._02, _12 - m._12, _22 - m._22
		);
	}

	@:extern public inline function mult(value: Float): Matrix3 {
		return new Matrix3(
			_00 * value, _10 * value, _20 * value,
			_01 * value, _11 * value, _21 * value,
			_02 * value, _12 * value, _22 * value
		);
	}

	@:extern public inline function transpose(): Matrix3 {
		return new Matrix3(
			_00, _01, _02,
			_10, _11, _12,
			_20, _21, _22
		);
	}

	@:extern public inline function trace(): Float {
		return _00 + _11 + _22;
	}

	@:extern public inline function multmat(m: Matrix3): Matrix3 {
		return new Matrix3(
			_00 * m._00 + _10 * m._01 + _20 * m._02, _00 * m._10 + _10 * m._11 + _20 * m._12, _00 * m._20 + _10 * m._21 + _20 * m._22,
			_01 * m._00 + _11 * m._01 + _21 * m._02, _01 * m._10 + _11 * m._11 + _21 * m._12, _01 * m._20 + _11 * m._21 + _21 * m._22,
			_02 * m._00 + _12 * m._01 + _22 * m._02, _02 * m._10 + _12 * m._11 + _22 * m._12, _02 * m._20 + _12 * m._21 + _22 * m._22
		);
	}

	@:extern public inline function multvec(value: Vector2): Vector2 {
		//var product = new Vector2(0, 0);
		var w = _02 * value.x + _12 * value.y + _22 * 1;
		var x = (_00 * value.x + _10 * value.y + _20 * 1) / w;
		var y = (_01 * value.x + _11 * value.y + _21 * 1) / w;
		return new Vector2(x, y);
	}

	@:extern public inline function determinant(): Float
	{
		return
		    _00 * ( _11 * _22 - _21 * _12 )
		  - _10 * ( _01 * _22 - _21 * _02 )
		  + _20 * ( _01 * _12 - _11 * _02 );
	}

	@:extern public inline function inverse(): Matrix3
	{
		var det = determinant();
		if( det < 0.0000001 )
			throw "determinant is too small";
		return new Matrix3(
			(_11 * _22 - _21 * _12) / det, (_20 * _12 - _10 * _22) / det, (_10 * _21 - _20 * _11) / det,
			(_21 * _02 - _01 * _22) / det, (_00 * _22 - _20 * _02) / det, (_20 * _01 - _00 * _21) / det,
			(_01 * _12 - _11 * _02) / det, (_10 * _02 - _00 * _12) / det, (_00 * _11 - _10 * _01) / det
		);
	}
}
