package kha.scene;

import kha.math.Vector3;

class Mesh {
	public function new() {
		
	}
	
	public function render(anim: Int = -1) {
		
	}
	
	public var size(get, null): Vector3;
	
	public function get_size(): Vector3 {
		return null;
	}
	
	private var posvertices: Array<Float>;
	private var indices: Array<Int>;
	
	public var xmin: Float;
	public var xmax: Float;
	public var ymin: Float;
	public var ymax: Float;
	public var zmin: Float;
	public var zmax: Float;

	public var material: Material;
}
