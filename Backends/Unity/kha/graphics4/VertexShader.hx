package kha.graphics4;

import kha.Blob;

class VertexShader {
	public var shader: Dynamic;
	public var name: String;

	public function new(sources: Array<Blob>, names: Array<String>) {
		if (sources != null) {
			shader = sources[0].bytes.getData();
			name = names[0];
		}
	}
}
