package kha.graphics4;

class FragmentShader {
	public var shader: Dynamic;
	
	public function new(source: Blob, name: String) {
		shader = Krom.createFragmentShader(source.bytes.getData(), name);
	}
}
