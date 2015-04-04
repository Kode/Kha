package kha.graphics4;

import unityEngine.Mesh;

class VertexBuffer {
	public var mesh: Mesh;
	private var vertices: Array<Float>;
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false) {
		mesh = new Mesh();
		vertices = new Array<Float>();
	}

	public function lock(?start: Int, ?count: Int): Array<Float> {
		return vertices;
	}

	public function unlock(): Void {
		
	}

	public function count(): Int {
		return 0;
	}

	public function stride(): Int {
		return 1;
	}
}
