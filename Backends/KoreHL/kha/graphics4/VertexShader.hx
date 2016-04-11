package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

class VertexShader {
	public var _shader: Pointer;
	
	public function new(source: Blob) {
		initVertexShader(source);
	}
	
	private function initVertexShader(source: Blob): Void {
		_shader = kore_create_vertexshader(source.bytes.getData().b, source.bytes.getData().length);
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
	
	@:hlNative("std", "kore_create_vertexshader") static function kore_create_vertexshader(data: hl.types.Bytes, length: Int): Pointer { return null; }
}
