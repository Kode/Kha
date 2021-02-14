package kha.graphics4;

import js.html.webgl.GL;

class FragmentShader {
	public var sources: Array<String>;
	public var type: Dynamic;
	public var shader: Dynamic;
	public var files: Array<String>;

	public function new(sources: Array<Blob>, files: Array<String>) {
		this.sources = [];
		for (source in sources) {
			this.sources.push(source.toString());
		}
		this.type = GL.FRAGMENT_SHADER;
		this.shader = null;
		this.files = files;
	}

	public static function fromSource(source: String): FragmentShader {
		var shader = new FragmentShader([], ["runtime-string"]);
		shader.sources.push(source);
		return shader;
	}

	public function delete(): Void {
		SystemImpl.gl.deleteShader(shader);
		shader = null;
		sources = null;
	}
}
