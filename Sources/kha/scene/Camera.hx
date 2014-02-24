package kha.scene;

import kha.math.Vector3;

class Camera {
	public function new() {
		
	}

	public var eye: Vector3;
	public var at: Vector3;
	public var up: Vector3;
	public var zNear: Float;
	public var zFar: Float;
}
