package kha.graphics4;

class FragmentShader {
	public var shader: Dynamic;
	
	public function new(sources: Array<Blob>, names: Array<String>) {
		if (sources != null) {
			shader = Krom.createFragmentShader(sources[0].bytes.getData(), names[0]);
		}
	}

	public static function fromSource(source: String): FragmentShader {
		var shader = new FragmentShader(null, null);
		shader.shader = Krom.createFragmentShaderFromSource(source);
		return shader;
	}

	public function delete() {
		Krom.deleteShader(shader);
		shader = null;
	}
}
