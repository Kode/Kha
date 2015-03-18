package kha.math;
import haxe.ds.Vector;

class Matrix4 {
	private static inline var width: Int = 4;
	private static inline var height: Int = 4;
	
	public function new(values: Array<Float>) {
		matrix = values;
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
		m.set(0, 3, x);
		m.set(1, 3, y);
		m.set(2, 3, z);
		return m;
	}
	
	public static function empty(): Matrix4 {
		return new Matrix4([
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0
		]);
	}

	public static function identity(): Matrix4 {
		return new Matrix4([
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		]);
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
	
	public static function orthogonalProjection(left: Float, right: Float, bottom: Float, top: Float, zn: Float, zf: Float): Matrix4 {
		var tx: Float = -(right + left) / (right - left);
		var ty: Float = -(top + bottom) / (top - bottom);
		var tz: Float = -(zf + zn) / (zf - zn);
		//var tz : Float = -zn / (zf - zn);
		return new Matrix4([
			2 / (right - left), 0,                  0,              0,
			0,                  2 / (top - bottom), 0,              0,
			0,                  0,                  -2 / (zf - zn), 0,
			tx,                 ty,                 tz,             1
		]);
	}
	
	public static function perspectiveProjection(fovY: Float, aspect: Float, zn: Float, zf: Float): Matrix4 {
		/*var f = Math.cos(2 / fovY);
		return new Matrix4([
			-f / aspect, 0, 0,                       0,
			0,           f, 0,                       0,
			0,           0, (zf + zn) / (zn - zf),   -1,
			0,           0, 2 * zf * zn / (zn - zf), 0
		]); */
		
		
		var result: Matrix4 = Matrix4.empty();
		
		
        var tanHalfFov: Float = Math.tan(fovY * 0.5);

        result.set(0, 0, 1 / (aspect * tanHalfFov));
		result.set(1, 1, 1 / tanHalfFov);
		result.set(2, 2, zf / (zn - zf));
		result.set(3, 2, -1);
		result.set(2, 3, (zf * zn) / (zn - zf));
		result.set(3, 3, 0);
        
        		
		return result;
		
	}
	
	public static function lookAt(eye: Vector3, at: Vector3, up: Vector3): Matrix4 {
		var zaxis = at.sub(eye);
		zaxis.normalize();
		var xaxis = zaxis.cross(up);
		xaxis.normalize();
		var yaxis = xaxis.cross(zaxis);

		/* var view = new Matrix4([
			xaxis.x, yaxis.x, -zaxis.x, 0,
			xaxis.y, yaxis.y, -zaxis.y, 0,
			xaxis.z, yaxis.z, -zaxis.z, 0,
			-xaxis.dot(eye),       -yaxis.dot(eye),       -zaxis.dot(eye),        1
		]); */
		
		/*
		var view = new Matrix4([
			xaxis.x, yaxis.y, -zaxis.z, 0,
			xaxis.x, yaxis.y, -zaxis.z, 0, 
			xaxis.x, yaxis.y, -zaxis.z, 0,
			0,       0,       0,        1
		]); 

		
		
		return view.multmat(translation(-eye.x, -eye.y, -eye.z)); */
		
		
		var result: Matrix4 = Matrix4.identity();
	
		var f: Vector3 = at.sub(eye);
		f.normalize();
		
		var u: Vector3 = up;
		u.normalize();
		
		var s: Vector3 = f.cross(u);
		s.normalize();
		
		u = s.cross(f);
		
		
		

		
		result.set(0, 0, s.x);
		result.set(1, 0, s.y);
		result.set(2, 0, s.z);
		result.set(0, 1, u.x);
		result.set(1, 1, u.y);
		result.set(2, 1, u.z);
		result.set(0, 2, -f.x);
		result.set(1, 2, -f.y);
		result.set(2, 2, -f.z);
		result.set(3, 0, -s.dot(eye));
		result.set(3, 1, -u.dot(eye));
		result.set(3, 2,  f.dot(eye));
		return result;
		
	}
	
	public function add(value: Matrix4): Matrix4 {
		var m = empty();
		for (i in 0...width * height) m.matrix[i] = matrix[i] + value.matrix[i];
		return m;
	}

	public function sub(value: Matrix4): Matrix4 {
		var m = empty();
		for (i in 0...width * height) m.matrix[i] = matrix[i] - value.matrix[i];
		return m;
	}

	public function mult(value: Float): Matrix4 {
		var m = empty();
		for (i in 0...width * height) m.matrix[i] = matrix[i] * value;
		return m;
	}
	
	public function transpose(): Matrix4 {
		var m = empty();
		for (x in 0...width) for (y in 0...height) m.set(y, x, get(x, y));
		return m;
	}

	public function transpose3x3(): Matrix4 {
		var m = empty();
		for (x in 0...3) for (y in 0...3) m.set(y, x, get(x, y));
		for (x in 3...width) for (y in 3...height) m.set(x, y, get(x, y));
		return m;
	}
	
	public function trace(): Float {
		var value: Float = 0;
		for (x in 0...width) value += get(x, x);
		return value;
	}
	
	public function multmat(value: Matrix4): Matrix4 {
		var m = empty();
		for (x in 0...width) for (y in 0...height) {
			var f: Float = 0;
			for (i in 0...width) f += get(i, y) * value.get(x, i);
			m.set(x, y, f);
		}
		return m;
	}

	public function multvec(value: Vector4): Vector4 {
		var product = new Vector4();
		for (y in 0...height) {
			var f: Float = 0;
			for (i in 0...width) f += get(i, y) * value.get(i);
			product.set(y, f);
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
		var inv: Vector<Float> = new Vector<Float>(16);
		var det: Float;
		
		

		inv[0] = matrix[5]  * matrix[10] * matrix[15] - 
				 matrix[5]  * matrix[11] * matrix[14] - 
				 matrix[9]  * matrix[6]  * matrix[15] + 
				 matrix[9]  * matrix[7]  * matrix[14] +
				 matrix[13] * matrix[6]  * matrix[11] - 
				 matrix[13] * matrix[7]  * matrix[10];

		inv[4] = -matrix[4]  * matrix[10] * matrix[15] + 
				  matrix[4]  * matrix[11] * matrix[14] + 
				  matrix[8]  * matrix[6]  * matrix[15] - 
				  matrix[8]  * matrix[7]  * matrix[14] - 
				  matrix[12] * matrix[6]  * matrix[11] + 
				  matrix[12] * matrix[7]  * matrix[10];

		inv[8] = matrix[4]  * matrix[9] * matrix[15] - 
				 matrix[4]  * matrix[11] * matrix[13] - 
				 matrix[8]  * matrix[5] * matrix[15] + 
				 matrix[8]  * matrix[7] * matrix[13] + 
				 matrix[12] * matrix[5] * matrix[11] - 
				 matrix[12] * matrix[7] * matrix[9];

		inv[12] = -matrix[4]  * matrix[9] * matrix[14] + 
				   matrix[4]  * matrix[10] * matrix[13] +
				   matrix[8]  * matrix[5] * matrix[14] - 
				   matrix[8]  * matrix[6] * matrix[13] - 
				   matrix[12] * matrix[5] * matrix[10] + 
				   matrix[12] * matrix[6] * matrix[9];

		inv[1] = -matrix[1]  * matrix[10] * matrix[15] + 
				  matrix[1]  * matrix[11] * matrix[14] + 
				  matrix[9]  * matrix[2] * matrix[15] - 
				  matrix[9]  * matrix[3] * matrix[14] - 
				  matrix[13] * matrix[2] * matrix[11] + 
				  matrix[13] * matrix[3] * matrix[10];

		inv[5] = matrix[0]  * matrix[10] * matrix[15] - 
				 matrix[0]  * matrix[11] * matrix[14] - 
				 matrix[8]  * matrix[2] * matrix[15] + 
				 matrix[8]  * matrix[3] * matrix[14] + 
				 matrix[12] * matrix[2] * matrix[11] - 
				 matrix[12] * matrix[3] * matrix[10];

		inv[9] = -matrix[0]  * matrix[9] * matrix[15] + 
				  matrix[0]  * matrix[11] * matrix[13] + 
				  matrix[8]  * matrix[1] * matrix[15] - 
				  matrix[8]  * matrix[3] * matrix[13] - 
				  matrix[12] * matrix[1] * matrix[11] + 
				  matrix[12] * matrix[3] * matrix[9];

		inv[13] = matrix[0]  * matrix[9] * matrix[14] - 
				  matrix[0]  * matrix[10] * matrix[13] - 
				  matrix[8]  * matrix[1] * matrix[14] + 
				  matrix[8]  * matrix[2] * matrix[13] + 
				  matrix[12] * matrix[1] * matrix[10] - 
				  matrix[12] * matrix[2] * matrix[9];

		inv[2] = matrix[1]  * matrix[6] * matrix[15] - 
				 matrix[1]  * matrix[7] * matrix[14] - 
				 matrix[5]  * matrix[2] * matrix[15] + 
				 matrix[5]  * matrix[3] * matrix[14] + 
				 matrix[13] * matrix[2] * matrix[7] - 
				 matrix[13] * matrix[3] * matrix[6];

		inv[6] = -matrix[0]  * matrix[6] * matrix[15] + 
				  matrix[0]  * matrix[7] * matrix[14] + 
				  matrix[4]  * matrix[2] * matrix[15] - 
				  matrix[4]  * matrix[3] * matrix[14] - 
				  matrix[12] * matrix[2] * matrix[7] + 
				  matrix[12] * matrix[3] * matrix[6];

		inv[10] = matrix[0]  * matrix[5] * matrix[15] - 
				  matrix[0]  * matrix[7] * matrix[13] - 
				  matrix[4]  * matrix[1] * matrix[15] + 
				  matrix[4]  * matrix[3] * matrix[13] + 
				  matrix[12] * matrix[1] * matrix[7] - 
				  matrix[12] * matrix[3] * matrix[5];

		inv[14] = -matrix[0]  * matrix[5] * matrix[14] + 
				   matrix[0]  * matrix[6] * matrix[13] + 
				   matrix[4]  * matrix[1] * matrix[14] - 
				   matrix[4]  * matrix[2] * matrix[13] - 
				   matrix[12] * matrix[1] * matrix[6] + 
				   matrix[12] * matrix[2] * matrix[5];

		inv[3] = -matrix[1] * matrix[6] * matrix[11] + 
				  matrix[1] * matrix[7] * matrix[10] + 
				  matrix[5] * matrix[2] * matrix[11] - 
				  matrix[5] * matrix[3] * matrix[10] - 
				  matrix[9] * matrix[2] * matrix[7] + 
				  matrix[9] * matrix[3] * matrix[6];

		inv[7] = matrix[0] * matrix[6] * matrix[11] - 
				 matrix[0] * matrix[7] * matrix[10] - 
				 matrix[4] * matrix[2] * matrix[11] + 
				 matrix[4] * matrix[3] * matrix[10] + 
				 matrix[8] * matrix[2] * matrix[7] - 
				 matrix[8] * matrix[3] * matrix[6];

		inv[11] = -matrix[0] * matrix[5] * matrix[11] + 
				   matrix[0] * matrix[7] * matrix[9] + 
				   matrix[4] * matrix[1] * matrix[11] - 
				   matrix[4] * matrix[3] * matrix[9] - 
				   matrix[8] * matrix[1] * matrix[7] + 
				   matrix[8] * matrix[3] * matrix[5];

		inv[15] = matrix[0] * matrix[5] * matrix[10] - 
				  matrix[0] * matrix[6] * matrix[9] - 
				  matrix[4] * matrix[1] * matrix[10] + 
				  matrix[4] * matrix[2] * matrix[9] + 
				  matrix[8] * matrix[1] * matrix[6] - 
				  matrix[8] * matrix[2] * matrix[5];

		det = matrix[0] * inv[0] + matrix[1] * inv[4] + matrix[2] * inv[8] + matrix[3] * inv[12];

		if (det == 0)
			throw "No Inverse";

		det = 1.0 / det;

		var result: Matrix4 = Matrix4.empty();
		for (i in 0...16) {
			result.matrix[i] = inv[i] * det;
		}
		
		return result;
		
		
		
		/*if (determinant() == 0) throw "No Inverse";
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
		} */
		// for (i in 0...width) for (j in 0...width) if (get(j, i) != ((i == j) ? 1 : 0)) throw "Matrix inversion error";
		// return inv;
	}
}
