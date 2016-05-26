package kha.graphics4;

import js.html.webgl.GL;

class FragmentShader {
	public var source: String;
	public var type: Dynamic;
	public var shader: Dynamic;
	
	public function new(source: Blob, name: String) {
		this.source = source.toString();
		this.type = GL.FRAGMENT_SHADER;
		this.shader = null;
	}
}
