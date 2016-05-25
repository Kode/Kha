package kha.graphics4;

import js.html.webgl.GL;

class VertexShader {
	public var source: String;
	public var type: Dynamic;
	public var shader: Dynamic;
	public var name: String;
	
	public function new(source: Blob, name: String) {
		this.source = source.toString();
		this.type = GL.VERTEX_SHADER;
		this.shader = null;
		this.name = name;
	}
}
