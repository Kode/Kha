package kha.math;


import kha.math.Vector3;
import kha.math.Matrix4;

// TODO: Check for my own changes

class Quaternion
{
	private var values: Array<Float>;
	
	public function new(x: Float = 0, y: Float = 0, z: Float = 0, w: Float = 1): Void {
		values = new Array<Float>();
		values.push(x);
		values.push(y);
		values.push(z);
		values.push(w);
	}
	
	// Axis has to be normalized
	public static function fromAxisAngle(axis: Vector3, radians: Float): Quaternion {
		var q: Quaternion = new Quaternion();
		q.w = Math.cos(radians / 2.0);
		q.x = q.y = q.z = Math.sin(radians / 2.0);
		q.x *= axis.x;
		q.y *= axis.y;
		q.z *= axis.z;
		return q;
	}
	
	public function slerp(t: Float, q: Quaternion) {
		var epsilon: Float = 0.0005;
		
		var dot = dot(q);
		
		if (dot > 1 - epsilon) {
			var result: Quaternion = q.add((this.sub(q)).scaled(t));
			result.normalize();
			return result;
		}
		if (dot < 0) dot = 0;
		if (dot > 1) dot = 1;

		var theta0: Float = Math.acos(dot);
		var theta: Float = theta0 * t;

		var q2: Quaternion = q.sub(scaled(dot));
		q2.normalize();

		var result: Quaternion = scaled(Math.cos(theta)).add(q2.scaled(Math.sin(theta)));
		
		result.normalize();

		return result;
	}
	
	// TODO: This should be multiplication
	public function rotated(b: Quaternion): Quaternion {
		var q: Quaternion = new Quaternion();
		q.w = w * b.w - x * b.x - y * b.y - z * b.z;
		q.x = w * b.x + x * b.w + y * b.z - z * b.y;
		q.y = w * b.y + y * b.w + z * b.x - x * b.z;
		q.z = w * b.z + z * b.w + x * b.y - y * b.x;
		q.normalize();
		return q;
	}
	
	public function scaled(scale: Float): Quaternion {
		return new Quaternion(x * scale, y * scale, z * scale, w * scale);
	}
	
	public function scale(scale: Float) {
		x = x * scale;
		y = y * scale;
		z = z * scale;
		w = w * scale;
	}
	
	public function matrix(): Matrix4 {
		var s: Float = 2.0;
		
		var xs: Float = x * s;
		var ys: Float = y * s;
		var zs: Float = z * s;
		var wx: Float = w * xs;
		var wy: Float = w * ys;
		var wz: Float = w * zs;
		var xx: Float = x * xs; 
		var xy: Float = x * ys;
		var xz: Float = x * zs;
		var yy: Float = y * ys;
		var yz: Float = y * zs;
		var zz: Float = z * zs;

		return new Matrix4(
			1 - (yy + zz), xy - wz, xz + wy, 0,
			xy + wz, 1 - (xx + zz), yz - wx, 0,
			xz - wy, yz + wx, 1 - (xx + yy), 0,
			0, 0, 0, 1
		);
	}
	
	
	public function get(index: Int): Float {
		return values[index];
	}
	
	public function set(index: Int, value: Float): Void {
		values[index] = value;
	}
	
	public var x(get, set): Float;
	public var y(get, set): Float;
	public var z(get, set): Float;
	public var w(get, set): Float;
	public var length(get, set): Float;
	
	public function get_x(): Float {
		return values[0];
	}
	
	public function set_x(value: Float): Float {
		return values[0] = value;
	}
	
	public function get_y(): Float {
		return values[1];
	}
	
	public function set_y(value: Float): Float {
		return values[1] = value;
	}
	
	public function get_z(): Float {
		return values[2];
	}
	
	public function set_z(value: Float): Float {
		return values[2] = value;
	}
	
	public function get_w(): Float {
		return values[3];
	}
	
	public function set_w(value: Float): Float {
		return values[3] = value;
	}
	
	// TODO: Isn't this code wrong? Is wrong in Vector4 for sure! (Missing w in the length)
	private function get_length(): Float {
		return Math.sqrt(x * x + y * y + z * z + w * w);
	}
	
	private function set_length(length: Float): Float {
		if (get_length() == 0) return 0;
		var mul = length / get_length();
		x *= mul;
		y *= mul;
		z *= mul;
		return length;
	}
	
	// For adding a (scaled) axis-angle representation of a quaternion
	public function addVector(vec: Vector3): Quaternion {
		var result: Quaternion = new Quaternion(x, y, z, w);
		var q1: Quaternion = new Quaternion(0, vec.x, vec.y, vec.z);
	
		q1 = q1.mult(result);
        
		result.x += q1.x * 0.5;
		result.y += q1.y * 0.5;
		result.z += q1.z * 0.5;
		result.w += q1.w * 0.5;
		return result;
	}
	
	public function add(q: Quaternion): Quaternion {
		return new Quaternion(x + q.x, y + q.y, z + q.z, w + q.w);
	}
	
	public function sub(q: Quaternion): Quaternion {
		return new Quaternion(x - q.x, y - q.y, z - q.z, w - q.w);
	}

	// TODO: Check again, but I think the code in Kore is wrong
	public function mult(r: Quaternion): Quaternion {
		var q: Quaternion = new Quaternion();
		q.x = w * r.x + x * r.w + y * r.z - z * r.y;
		q.y = w * r.y - x * r.z + y * r.w + z * r.x;
		q.z = w * r.z + x * r.y - y * r.x + z * r.w;
		q.w = w * r.w - x * r.x - y * r.y - z * r.z;
		return q;
	}
	
	public function normalize() {
		scale(1.0 / length);
	}
	
	public function dot(q: Quaternion) {
		return x * q.x + y * q.y + z * q.z + w * q.w;
	}
	
	
	// GetEulerAngles extracts Euler angles from the quaternion, in the specified order of
    // axis rotations and the specified coordinate system. Right-handed coordinate system
    // is the default, with CCW rotations while looking in the negative axis direction.
    // Here a,b,c, are the Yaw/Pitch/Roll angles to be returned.
    // rotation a around axis A1
    // is followed by rotation b around axis A2
    // is followed by rotation c around axis A3
    // rotations are CCW or CW (D) in LH or RH coordinate system (S)
	
	
	public static inline var AXIS_X: Int = 0;
	public static inline var AXIS_Y: Int = 1;
	public static inline var AXIS_Z: Int = 2;
	
	
	public function getEulerAngles(A1: Int, A2: Int, A3: Int, S: Int = 1, D:Int = 1): Vector3 {
		
		var result: Vector3 = new Vector3();
        
		
		var Q: Array<Float> = new Array<Float>();
		Q[0] = x;
		Q[1] = y;
		Q[2] = z;
		
        var ww: Float = w * w;
        
		var Q11: Float = Q[A1]*Q[A1];
        var Q22: Float = Q[A2]*Q[A2];
        var Q33: Float = Q[A3]*Q[A3];

        var psign: Float = -1;
		
		var SingularityRadius: Float = 0.0000001;
		var PiOver2: Float = Math.PI / 2.0;
		
        // Determine whether even permutation
        if (((A1 + 1) % 3 == A2) && ((A2 + 1) % 3 == A3))
            psign = 1;
        
        var s2: Float = psign * 2.0 * (psign*w*Q[A2] + Q[A1]*Q[A3]);

		
        if (s2 < -1 + SingularityRadius)
        { // South pole singularity
            result.x = 0;
            result.y = -S*D*PiOver2;
            result.z = S*D*Math.atan2(2*(psign*Q[A1]*Q[A2] + w*Q[A3]),
		                   ww + Q22 - Q11 - Q33 );
        }
        else if (s2 > 1 - SingularityRadius)
        {  // North pole singularity
            result.x = 0;
            result.y = S*D*PiOver2;
            result.z = S*D*Math.atan2(2*(psign*Q[A1]*Q[A2] + w*Q[A3]),
		                   ww + Q22 - Q11 - Q33);
        }
        else
        {
            result.x = -S*D*Math.atan2(-2*(w*Q[A1] - psign*Q[A2]*Q[A3]),
		                    ww + Q33 - Q11 - Q22);
            result.y = S*D*Math.asin(s2);
            result.z = S*D*Math.atan2(2*(w*Q[A3] - psign*Q[A1]*Q[A2]),
		                   ww + Q11 - Q22 - Q33);
        }      
		
		return result;
    }
	
}


