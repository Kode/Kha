package kha.graphics4;

class TessellationEvaluationShader {
	public var shader: Dynamic;
	
	public function new(source: Blob, name: String) {
		shader = Krom.createTessellationEvaluationShader(source.bytes.getData(), name);
	}

	public function delete() {
		Krom.deleteShader(shader);
		shader = null;
	}
}
