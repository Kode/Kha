package kha.graphics4;

class VertexShader {
	public var sources: Array<String>;
	public var type: Dynamic;
	public var shader: Dynamic;
	public var files: Array<String>;
	
	public function new(sources: Array<Blob>, files: Array<String>) {
		
	}
	
	public static function fromSource(source: String): FragmentShader {
		return null;
	}
	
	public function delete(): Void {
		shader = null;
		sources = null;
	}
}
