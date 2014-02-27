package kha.scene;

import kha.graphics.Texture;
import kha.math.Vector3;

class Particle {
	public var image: Texture;
	public var position: Vector3;
	public var speed: Vector3;
	public var acceleration: Vector3;
	public var lifetime: Float;
	public var alive: Float = 0;

	public function new() {
		
	}
}
