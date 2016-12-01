package kha.graphics4;

class VertexShader {
	public var shader: Dynamic;
	
	public function new(source: Blob, name: String) {
		shader = Krom.createVertexShader(source.bytes.getData(), name);
	}

	public function delete() {
		Krom.deleteShader(shader);
		shader = null;
	}
}
