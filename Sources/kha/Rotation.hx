package kha;

import kha.math.Vector2;

class Rotation {
	public var center: Vector2;
	public var angle: Float;
	
	public function new(center: Vector2, angle: Float) {
		this.center = center;
		this.angle = angle;
	}
}
