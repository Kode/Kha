package kha.graphics4;

class VertexShader {
	public var shader: Dynamic;
	
	public function new(sources: Array<Blob>, names: Array<String>) {
		shader = Krom.createVertexShader(sources[0].bytes.getData(), names[0]);
	}

	public function delete() {
		Krom.deleteShader(shader);
		shader = null;
	}
}
