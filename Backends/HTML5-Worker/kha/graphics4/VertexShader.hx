package kha.graphics4;

class VertexShader {
	public var sources: Array<String>;
	public var shader: Dynamic;
	public var files: Array<String>;
	
	public function new(sources: Array<Blob>, files: Array<String>) {
		this.sources = [];
		for (source in sources) {
			this.sources.push(source.toString());
		}
		this.shader = null;
		this.files = files;
	}

	public static function fromSource(source: String): VertexShader {
		var shader = new VertexShader([], ["runtime-string"]);
		shader.sources.push(source);
		return shader;
	}
	
	public function delete(): Void {
		shader = null;
		sources = null;
	}
}
