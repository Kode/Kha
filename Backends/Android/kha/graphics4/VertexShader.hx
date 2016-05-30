package kha.graphics4;

import android.opengl.GLES20;

class VertexShader {
	public var source: String;
	public var type: Int;
	public var shader: Int;
	
	public function new(source: Blob, file: String) {
		this.source = source.toString();
		this.type = GLES20.GL_VERTEX_SHADER;
		this.shader = -1;
	}
}
