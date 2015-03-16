package kha.vr;

import kha.math.Quaternion;
import kha.math.Vector3;

// Position and orientation together.
class Pose {
	public var Orientation: Quaternion;
    public var Position: Vector3;
	
	public function new() {
		Orientation = new Quaternion();
		Position = new Vector3();
	}
}