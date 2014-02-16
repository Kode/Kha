package kha.scene;

import kha.math.Vector3;

class Mesh {
	public function render(anim: Int = -1) {
		
	}
	
	public var size(get, null): Vector3;
	
	public function get_size(): Vector3 {
		return null;
	}
	
	private var posvertices: Array<Float>;
	private var indices: Array<Int>;
	
	private var xmin: Float;
	private var xmax: Float;
	private var ymin: Float;
	private var ymax: Float;
	private var zmin: Float;
	private var zmax: Float;

	private var material: Material;
}
