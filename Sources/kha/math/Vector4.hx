package kha.math;

class Vector4 {
	private var values: Array<Float>;
	
	public function new(x: Float = 0, y: Float = 0, z: Float = 0, w: Float = 1): Void {
		values = new Array<Float>();
		values.push(x);
		values.push(y);
		values.push(z);
		values.push(w);
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
	
	private function get_length(): Float {
		return Math.sqrt(x * x + y * y + z * z);
	}
	
	private function set_length(length: Float): Float {
		if (get_length() == 0) return 0;
		var mul = length / get_length();
		x *= mul;
		y *= mul;
		z *= mul;
		return length;
	}
	
	public function add(vec: Vector4): Vector4 {
		return new Vector4(x + vec.x, y + vec.y, z + vec.z);
	}
	
	public function sub(vec: Vector4): Vector4 {
		return new Vector4(x - vec.x, y - vec.y, z - vec.z);
	}
	
	public function mult(value: Float): Vector4 {
		return new Vector4(x * value, y * value, z * value);
	}
}
