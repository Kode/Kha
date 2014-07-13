package kha.math;

abstract Matrix3(Array<Float>) {
	private static inline var width: Int = 4;
	private static inline var height: Int = 4;
	
	public function new(values: Array<Float>) {
		this = values;
	}
	
	@:arrayAccess public inline function get(index: Int): Float {
		return this[index];
	}

	@:arrayAccess public inline function set(index: Int, value: Float): Float {
		this[index] = value;
		return value;
	}
	
	public static function index(x: Int, y: Int): Int {
		return y * width + x;
	}
	
	public static inline function translation(x: Float, y: Float): Matrix3 {
		return new Matrix3([
			1, 0, x,
			0, 1, y,
			0, 0, 1
		]);
	}
	
	public static inline function empty(): Matrix3 {
		return new Matrix3([
			0, 0, 0,
			0, 0, 0,
			0, 0, 0
		]);
	}

	public static inline function identity(): Matrix3 {
		return new Matrix3([
			1, 0, 0,
			0, 1, 0,
			0, 0, 1
		]);
	}
}
