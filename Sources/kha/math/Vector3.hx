package kha.math;

class Vector3 {
	public function new(x: Float = 0, y: Float = 0, z: Float = 0): Void {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public var x: Float;
	public var y: Float;
	public var z: Float;
	public var length(getLength, setLength): Float;
	
	private function getLength(): Float {
		return Math.sqrt(x * x + y * y + z * z);
	}
	
	private function setLength(length: Float): Float {
		if (getLength() == 0) return 0;
		var mul = length / getLength();
		x *= mul;
		y *= mul;
		z *= mul;
		return length;
	}
	
	public function add(vec: Vector3): Vector3 {
		return new Vector3(x + vec.x, y + vec.y, z + vec.z);
	}
	
	public function sub(vec: Vector3): Vector3 {
		return new Vector3(x - vec.x, y - vec.y, z - vec.z);
	}
}
