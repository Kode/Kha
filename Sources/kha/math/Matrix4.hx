package kha.math;

class Matrix4 {
	private static inline var width: Int = 4;
	private static inline var height: Int = 4;

	public var _00: Float; public var _10: Float; public var _20: Float; public var _30: Float;
	public var _01: Float; public var _11: Float; public var _21: Float; public var _31: Float;
	public var _02: Float; public var _12: Float; public var _22: Float; public var _32: Float;
	public var _03: Float; public var _13: Float; public var _23: Float; public var _33: Float;

	public inline function new(_00: Float, _10: Float, _20: Float, _30: Float,
								_01: Float, _11: Float, _21: Float, _31: Float,
								_02: Float, _12: Float, _22: Float, _32: Float,
								_03: Float, _13: Float, _23: Float, _33: Float) {
		this._00 = _00; this._10 = _10; this._20 = _20; this._30 = _30;
		this._01 = _01; this._11 = _11; this._21 = _21; this._31 = _31;
		this._02 = _02; this._12 = _12; this._22 = _22; this._32 = _32;
		this._03 = _03; this._13 = _13; this._23 = _23; this._33 = _33;
	}

	@:extern public static inline function translation(x: Float, y: Float, z: Float): Matrix4 {
		return new Matrix4(
			1, 0, 0, x,
			0, 1, 0, y,
			0, 0, 1, z,
			0, 0, 0, 1
		);
	}

	@:extern public static inline function empty(): Matrix4 {
		return new Matrix4(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0
		);
	}

	@:extern public static inline function identity(): Matrix4 {
		return new Matrix4(
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		);
	}

	@:extern public static inline function scale(x: Float, y: Float, z: Float): Matrix4 {
		return new Matrix4(
			x, 0, 0, 0,
			0, y, 0, 0,
			0, 0, z, 0,
			0, 0, 0, 1
		);
	}

	@:extern public static inline function rotationX(alpha: Float): Matrix4 {
		var ca = Math.cos(alpha);
		var sa = Math.sin(alpha);
		return new Matrix4(
			1,  0,   0, 0,
			0, ca, -sa, 0,
			0, sa,  ca, 0,
			0,  0,   0, 1
		);
	}

	@:extern public static inline function rotationY(alpha: Float): Matrix4 {
		var ca = Math.cos(alpha);
		var sa = Math.sin(alpha);
		return new Matrix4(
			 ca, 0, sa, 0,
			  0, 1,  0, 0,
			-sa, 0, ca, 0,
			  0, 0,  0, 1
		);
	}

	@:extern public static inline function rotationZ(alpha: Float): Matrix4 {
		var ca = Math.cos(alpha);
		var sa = Math.sin(alpha);
		return new Matrix4(
			ca, -sa, 0, 0,
			sa,  ca, 0, 0,
			 0,   0, 1, 0,
			 0,   0, 0, 1
		);
	}

	@:extern public static inline function rotation(yaw: Float, pitch: Float, roll: Float): Matrix4 {
		var sy = Math.sin(yaw);
		var cy = Math.cos(yaw);
		var sx = Math.sin(pitch);
		var cx = Math.cos(pitch);
		var sz = Math.sin(roll);
		var cz = Math.cos(roll);
		return new Matrix4(
			cx * cy, cx * sy * sz - sx * cz, cx * sy * cz + sx * sz, 0,
			sx * cy, sx * sy * sz + cx * cz, sx * sy * cz - cx * sz, 0,
				-sy,                cy * sz,                cy * cz, 0,
				  0,                      0,                      0, 1
		);
	}

	// Inlining this leads to weird error in C#, please investigate
	public static function orthogonalProjection(left: Float, right: Float, bottom: Float, top: Float, zn: Float, zf: Float): Matrix4 {
		var tx: Float = -(right + left) / (right - left);
		var ty: Float = -(top + bottom) / (top - bottom);
		var tz: Float = -(zf + zn) / (zf - zn);
		return new Matrix4(
			2 / (right - left), 0,                  0,              tx,
			0,                  2 / (top - bottom), 0,              ty,
			0,                  0,                  -2 / (zf - zn), tz,
			0,                  0,                  0,               1
		);
	}

	public static function perspectiveProjection(fovY: Float, aspect: Float, zn: Float, zf: Float): Matrix4 {
		var uh = 1.0 / Math.tan(fovY / 2);
		var uw = uh / aspect;
		return new Matrix4(
			uw, 0, 0, 0,
			0, uh, 0, 0,
			0, 0, (zf + zn) / (zn - zf), 2 * zf * zn / (zn - zf),
			0, 0, -1, 0
		);
	}

	public static function lookAt(eye: Vector3, at: Vector3, up: Vector3): Matrix4 {
		var zaxis = at.sub(eye);
		zaxis.normalize();
		var xaxis = zaxis.cross(up);
		xaxis.normalize();
		var yaxis = xaxis.cross(zaxis);

		return new Matrix4(
			xaxis.x, xaxis.y, xaxis.z, -xaxis.dot(eye),
			yaxis.x, yaxis.y, yaxis.z, -yaxis.dot(eye),
			-zaxis.x, -zaxis.y, -zaxis.z, zaxis.dot(eye),
			0, 0, 0, 1
		);
	}

	@:extern public inline function add(m: Matrix4): Matrix4 {
		return new Matrix4(
			_00 + m._00, _10 + m._10, _20 + m._20, _30 + m._30,
			_01 + m._01, _11 + m._11, _21 + m._21, _31 + m._31,
			_02 + m._02, _12 + m._12, _22 + m._22, _32 + m._32,
			_03 + m._03, _13 + m._13, _23 + m._23, _33 + m._33
		);
	}

	@:extern public inline function sub(m: Matrix4): Matrix4 {
		return new Matrix4(
			_00 - m._00, _10 - m._10, _20 - m._20, _30 - m._30,
			_01 - m._01, _11 - m._11, _21 - m._21, _31 - m._31,
			_02 - m._02, _12 - m._12, _22 - m._22, _32 - m._32,
			_03 - m._03, _13 - m._13, _23 - m._23, _33 - m._33
		);
	}

	@:extern public inline function mult(value: Float): Matrix4 {
		return new Matrix4(
			_00 * value, _10 * value, _20 * value, _30 * value,
			_01 * value, _11 * value, _21 * value, _31 * value,
			_02 * value, _12 * value, _22 * value, _32 * value,
			_03 * value, _13 * value, _23 * value, _33 * value
		);
	}

	@:extern public inline function transpose(): Matrix4 {
		return new Matrix4(
			_00, _01, _02, _03,
			_10, _11, _12, _13,
			_20, _21, _22, _23,
			_30, _31, _32, _33
		);
	}

	@:extern public inline function transpose3x3(): Matrix4 {
		return new Matrix4(
			_00, _01, _02, _30,
			_10, _11, _12, _31,
			_20, _21, _22, _32,
			_03, _13, _23, _33
		);
	}

	@:extern public inline function trace(): Float {
		return _00 + _11 + _22 + _33;
	}

	@:extern public inline function multmat(m: Matrix4): Matrix4 {
		return new Matrix4(
			_00 * m._00 + _10 * m._01 + _20 * m._02 + _30 * m._03, _00 * m._10 + _10 * m._11 + _20 * m._12 + _30 * m._13, _00 * m._20 + _10 * m._21 + _20 * m._22 + _30 * m._23, _00 * m._30 + _10 * m._31 + _20 * m._32 + _30 * m._33,
			_01 * m._00 + _11 * m._01 + _21 * m._02 + _31 * m._03, _01 * m._10 + _11 * m._11 + _21 * m._12 + _31 * m._13, _01 * m._20 + _11 * m._21 + _21 * m._22 + _31 * m._23, _01 * m._30 + _11 * m._31 + _21 * m._32 + _31 * m._33,
			_02 * m._00 + _12 * m._01 + _22 * m._02 + _32 * m._03, _02 * m._10 + _12 * m._11 + _22 * m._12 + _32 * m._13, _02 * m._20 + _12 * m._21 + _22 * m._22 + _32 * m._23, _02 * m._30 + _12 * m._31 + _22 * m._32 + _32 * m._33,
			_03 * m._00 + _13 * m._01 + _23 * m._02 + _33 * m._03, _03 * m._10 + _13 * m._11 + _23 * m._12 + _33 * m._13, _03 * m._20 + _13 * m._21 + _23 * m._22 + _33 * m._23, _03 * m._30 + _13 * m._31 + _23 * m._32 + _33 * m._33
		);
	}

	@:extern public inline function multvec(value: Vector4): Vector4 {
		var product = new Vector4();
		product.x = _00 * value.x + _10 * value.y + _20 * value.z + _30 * value.w;
		product.y = _01 * value.x + _11 * value.y + _21 * value.z + _31 * value.w;
		product.z = _02 * value.x + _12 * value.y + _22 * value.z + _32 * value.w;
		product.w = _03 * value.x + _13 * value.y + _23 * value.z + _33 * value.w;
		return product;
	}

    @:extern public inline function cofactor(m0: Float, m1: Float, m2: Float,
											m3: Float, m4: Float, m5: Float,
											m6: Float, m7: Float, m8: Float): Float {
		return m0 * ( m4 * m8 - m5 * m7 ) - m1 * ( m3 * m8 - m5 * m6 ) + m2 * ( m3 * m7 - m4 * m6 );
	}

	@:extern public inline function determinant(): Float {
		var c00 = cofactor(_11, _21, _31, _12, _22, _32, _13, _23, _33);
		var c01 = cofactor(_10, _20, _30, _12, _22, _32, _13, _23, _33);
		var c02 = cofactor(_10, _20, _30, _11, _21, _31, _13, _23, _33);
		var c03 = cofactor(_10, _20, _30, _11, _21, _31, _12, _22, _32);
		return _00 * c00 - _01 * c01 + _02 * c02 - _03 * c03;
	}

	@:extern public inline function inverse(): Matrix4 {
		var c00 = cofactor(_11, _21, _31, _12, _22, _32, _13, _23, _33);
		var c01 = cofactor(_10, _20, _30, _12, _22, _32, _13, _23, _33);
		var c02 = cofactor(_10, _20, _30, _11, _21, _31, _13, _23, _33);
		var c03 = cofactor(_10, _20, _30, _11, _21, _31, _12, _22, _32);

		var det: Float = _00 * c00 - _01 * c01 + _02 * c02 - _03 * c03;
		if (Math.abs(det) < 0.000001) {
            throw "determinant is too small";
		}

		var c10 = cofactor(_01, _21, _31, _02, _22, _32, _03, _23, _33);
		var c11 = cofactor(_00, _20, _30, _02, _22, _32, _03, _23, _33);
		var c12 = cofactor(_00, _20, _30, _01, _21, _31, _03, _23, _33);
		var c13 = cofactor(_00, _20, _30, _01, _21, _31, _02, _22, _32);

		var c20 = cofactor(_01, _11, _31, _02, _12, _32, _03, _13, _33);
		var c21 = cofactor(_00, _10, _30, _02, _12, _32, _03, _13, _33);
		var c22 = cofactor(_00, _10, _30, _01, _11, _31, _03, _13, _33);
		var c23 = cofactor(_00, _10, _30, _01, _11, _31, _02, _12, _32);

		var c30 = cofactor(_01, _11, _21, _02, _12, _22, _03, _13, _23);
		var c31 = cofactor(_00, _10, _20, _02, _12, _22, _03, _13, _23);
		var c32 = cofactor(_00, _10, _20, _01, _11, _21, _03, _13, _23);
		var c33 = cofactor(_00, _10, _20, _01, _11, _21, _02, _12, _22);

		var invdet: Float = 1.0 / det;
		return new Matrix4(
			 c00 * invdet, - c01 * invdet,   c02 * invdet, - c03 * invdet,
			-c10 * invdet,   c11 * invdet, - c12 * invdet,   c13 * invdet,
			 c20 * invdet, - c21 * invdet,   c22 * invdet, - c23 * invdet,
			-c30 * invdet,   c31 * invdet, - c32 * invdet,   c33 * invdet
		);
	}
}
