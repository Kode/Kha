package kha.graphics4;

import kha.Blob;

class VertexShader {
	public var source: String;
	public var type: Dynamic;
	public var shader: Dynamic;
	
	public function new(source: Blob) {
		this.source = source.toString();
		this.type = Sys.gl.VERTEX_SHADER;
		this.shader = null;
	}
}
