package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

class VertexShader {
	public var _shader: Pointer;
	
	public function new(sources: Array<Blob>, files: Array<String>) {
		initVertexShader(sources[0]);
	}
	
	private function initVertexShader(source: Blob): Void {
		_shader = kore_create_vertexshader(source.bytes.getData(), source.bytes.getData().length);
	}

	public static function fromSource(source: String): VertexShader {
		return null;
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
	
	@:hlNative("std", "kore_create_vertexshader") static function kore_create_vertexshader(data: hl.Bytes, length: Int): Pointer { return null; }
}
