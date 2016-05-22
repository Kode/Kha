package kha.graphics4;

class VertexShader {
	public var shader: Dynamic;
	
	public function new(source: Blob) {
		shader = Krom.createVertexShader(source.bytes.getData());
	}
}
