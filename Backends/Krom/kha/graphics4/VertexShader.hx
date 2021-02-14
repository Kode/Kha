package kha.graphics4;

class VertexShader {
	public var shader: Dynamic;

	public function new(sources: Array<Blob>, names: Array<String>) {
		if (sources != null) {
			shader = Krom.createVertexShader(sources[0].bytes.getData(), names[0]);
		}
	}

	public static function fromSource(source: String): VertexShader {
		var shader = new VertexShader(null, null);
		shader.shader = Krom.createVertexShaderFromSource(source);
		return shader;
	}

	public function delete() {
		Krom.deleteShader(shader);
		shader = null;
	}
}
