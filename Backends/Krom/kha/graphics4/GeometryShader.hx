package kha.graphics4;

class GeometryShader {
	public var shader: Dynamic;
	
	public function new(source: Blob, name: String) {
		shader = Krom.createGeometryShader(source.bytes.getData(), name);
	}

	public function delete() {
		
	}
}
