package kha.math;

abstract Matrix3(Array<Float>) {
	private static inline var width: Int = 3;
	private static inline var height: Int = 3;
	
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
	
	public static inline function scale(x: Float, y: Float): Matrix3 {
		var m = identity();
		m[index(0, 0)] = x;
		m[index(1, 1)] = y;
		return m;
	}

	public static function rotation(alpha: Float): Matrix3 {
		var m = identity();
		m[index(0, 0)] = Math.cos(alpha);
		m[index(1, 0)] = -Math.sin(alpha);
		m[index(0, 1)] = Math.sin(alpha);
		m[index(1, 1)] = Math.cos(alpha);
		return m;
	}
	
	@:op(A + B)
	public function add(value: Matrix3): Matrix3 {
		var m = empty();
		for (i in 0...width * height) m[i] = this[i] + value[i];
		return m;
	}

	@:op(A - B)
	public function sub(value: Matrix3): Matrix3 {
		var m = empty();
		for (i in 0...width * height) m[i] = this[i] - value[i];
		return m;
	}

	public function mult(value: Float): Matrix3 {
		var m = empty();
		for (i in 0...width * height) m[i] = this[i] * value;
		return m;
	}
	
	public function transpose(): Matrix3 {
		var m = empty();
		for (x in 0...width) for (y in 0...height) m[index(y, x)] = this[index(x, y)];
		return m;
	}
	
	public function trace(): Float {
		var value: Float = 0;
		for (x in 0...width) value += this[index(x, x)];
		return value;
	}
	
	@:op(A * B)
	public function multmat(value: Matrix3): Matrix3 {
		var m = empty();
		for (x in 0...width) for (y in 0...height) {
			var f: Float = 0;
			for (i in 0...width) f += this[index(i, y)] * value[index(x, i)];
			m[index(x, y)] = f;
		}
		return m;
	}
	
	public inline function multvec(value: Vector2): Vector2 {
		var product = new Vector2();
		var f: Float = 0;
		f += this[index(0, 2)] * value.x;
		f += this[index(1, 2)] * value.y;
		f += this[index(2, 2)] * 1;
		var w = f;
		f = 0;
		f += this[index(0, 0)] * value.x;
		f += this[index(1, 0)] * value.y;
		f += this[index(2, 0)] * 1;
		product.x = f / w;
		f = 0;
		f += this[index(0, 1)] * value.x;
		f += this[index(1, 1)] * value.y;
		f += this[index(2, 1)] * 1;
		product.y = f / w;
		return product;
	}

	/*public function determinant(): Float {
		return get(0, 0) * (
			  get(1, 1) * (get(2, 2) * get(3, 3) - get(3, 2) * get(2, 3))
			+ get(2, 1) * (get(3, 2) * get(1, 3) - get(1, 2) * get(3, 3))
			+ get(3, 1) * (get(1, 2) * get(2, 3) - get(2, 2) * get(1, 3))
		)
		- get(1, 0) * (
			  get(0, 1) * (get(2, 2) * get(3, 3) - get(3, 2) * get(2, 3))
			+ get(2, 1) * (get(3, 2) * get(0, 3) - get(0, 2) * get(3, 3))
			+ get(3, 1) * (get(0, 2) * get(2, 3) - get(2, 2) * get(0, 3))
		)
		+ get(2, 0) * (
			  get(0, 1) * (get(1, 2) * get(3, 3) - get(3, 2) * get(1, 3))
			+ get(1, 1) * (get(3, 2) * get(0, 3) - get(0, 2) * get(3, 3))
			+ get(3, 1) * (get(0, 2) * get(1, 3) - get(1, 2) * get(0, 3))
		)
		- get(3, 0) * (
			  get(0, 1) * (get(1, 2) * get(2, 3) - get(2, 2) * get(1, 3))
			+ get(1, 1) * (get(2, 2) * get(0, 3) - get(0, 2) * get(2, 3))
			+ get(2, 1) * (get(0, 2) * get(1, 3) - get(1, 2) * get(0, 3))
		);
	}*/

	/*public function inverse(): Matrix4 {
		if (determinant() == 0) throw "No Inverse";
		var q: Float;
		var inv = identity();

		for (j in 0...width) {
			q = get(j, j);
			if (q == 0) {
				for (i in j + 1...width) {
					if (get(j, i) != 0) {
						for (k in 0...width) {
							inv.set(k, j, get(k, j) + get(k, i));
						}
						q = get(j, j);
						break;
					}
				}
			}
			if (q != 0) {
				for (k in 0...width) {
					inv.set(k, j, get(k, j) / q);
				}
			}
			for (i in 0...width) {
				if (i != j) {
					q = get(j, i);
					for (k in 0...width) {
						inv.set(k, i, get(k, i) - q * get(k, j));
					}
				}
			}
		}
		for (i in 0...width) for (j in 0...width) if (get(j, i) != ((i == j) ? 1 : 0)) throw "Matrix inversion error";
		return inv;
	}*/
}
