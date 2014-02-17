package kha.math;

class Matrix4 {
	private static inline var width: Int = 4;
	private static inline var height: Int = 4;
	
	public function new() {
		matrix = new Array<Float>();
		for (i in 0...16) matrix.push(0);
	}
	
	public var matrix: Array<Float>;
	
	public function set(x: Int, y: Int, value: Float): Void {
		matrix[y * width + x] = value;
	}
	
	public function get(x: Int, y: Int): Float {
		return matrix[y * width + x];
	}

	public static function translation(x: Float, y: Float, z: Float): Matrix4 {
		var m = identity();
		m.set(3, 0, x);
		m.set(3, 1, y);
		m.set(3, 2, z);
		return m;
	}

	public static function identity(): Matrix4 {
		var m = new Matrix4();
		for (x in 0...width) m.set(x, x, 1);
		return m;
	}

	public static function scale(x: Float, y: Float, z: Float): Matrix4 {
		var m = identity();
		m.set(0, 0, x);
		m.set(1, 1, y);
		m.set(2, 2, z);
		return m;
	}

	public static function rotationX(alpha: Float): Matrix4 {
		var m = identity();
		m.set(1, 1, Math.cos(alpha));
		m.set(2, 1, -Math.sin(alpha));
		m.set(1, 2, Math.sin(alpha));
		m.set(2, 2, Math.cos(alpha));
		return m;
	}

	public static function rotationY(alpha: Float): Matrix4 {
		var m = identity();
		m.set(0, 0, Math.cos(alpha));
		m.set(2, 0, Math.sin(alpha));
		m.set(0, 2, -Math.sin(alpha));
		m.set(2, 2, Math.cos(alpha));
		return m;
	}

	public static function rotationZ(alpha: Float): Matrix4 {
		var m = identity();
		m.set(0, 0, Math.cos(alpha));
		m.set(1, 0, -Math.sin(alpha));
		m.set(0, 1, Math.sin(alpha));
		m.set(1, 1, Math.cos(alpha));
		return m;
	}
	
	public static function add(a: Matrix4, b: Matrix4): Matrix4 {
		var m = new Matrix4();
		for (i in 0...width * height) m.matrix[i] = a.matrix[i] + b.matrix[i];
		return m;
	}

	public static function sub(a: Matrix4, b: Matrix4): Matrix4 {
		var m = new Matrix4();
		for (i in 0...width * height) m.matrix[i] = a.matrix[i] - b.matrix[i];
		return m;
	}

	public static function mult(mat: Matrix4, value: Float): Matrix4 {
		var m = new Matrix4();
		for (i in 0...width * height) m.matrix[i] = mat.matrix[i] * value;
		return m;
	}
	
	public function transpose(): Matrix4 {
		var m = new Matrix4();
		for (x in 0...width) for (y in 0...height) m.set(y, x, get(x, y));
		return m;
	}

	public function transpose3x3(): Matrix4 {
		var m = new Matrix4();
		for (x in 0...3) for (y in 0...3) m.set(y, x, get(x, y));
		for (x in 3...width) for (y in 3...height) m.set(x, y, get(x, y));
		return m;
	}
	
	public function trace(): Float {
		var value: Float = 0;
		for (x in 0...width) value += get(x, x);
		return value;
	}
	
	public static function multmat(a: Matrix4, b: Matrix4): Matrix4 {
		var m = new Matrix4();
		for (x in 0...width) for (y in 0...height) {
			var value: Float = 0;
			for (i in 0...width) value += a.get(i, y) * b.get(x, i);
			m.set(x, y, value);
		}
		return m;
	}

	public static function multvec(a: Matrix4, v: Vector4): Vector4 {
		var product = new Vector4();
		for (y in 0...height) {
			var value: Float = 0;
			for (i in 0...width) value += a.get(i, y) * v.get(i);
			product.set(y, value);
		}
		return product;
	}

	public function determinant(): Float {
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
	}

	public function inverse(): Matrix4 {
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
	}
}
