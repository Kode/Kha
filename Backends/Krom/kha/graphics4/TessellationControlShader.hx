package kha.graphics4;

class TessellationControlShader {
	public var shader: Dynamic;
	
	public function new(source: Blob, name: String) {
		shader = Krom.createTessellationControlShader(source.bytes.getData(), name);
	}

	public function delete() {
		
	}
}
