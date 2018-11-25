package kha.graphics4;

import kha.Blob;

class VertexShader {
	public var _shader: Pointer;
	
	public function new(sources: Array<Blob>, files: Array<String>) {
		initShader(sources[0]);
	}
	
	private function initShader(source: Blob): Void {
		_shader = kore_create_vertexshader(source.bytes.getData(), source.bytes.getData().length);
	}

	public static function fromSource(source: String): VertexShader {
		var sh = new VertexShader(null, null);
		sh._shader = kore_vertexshader_from_source(StringHelper.convert(source));
		return sh;
	}

	public function delete(): Void {
		
	}
	
	@:hlNative("std", "kore_create_vertexshader") static function kore_create_vertexshader(data: hl.Bytes, length: Int): Pointer { return null; }
	@:hlNative("std", "kore_vertexshader_from_source") static function kore_vertexshader_from_source(source: hl.Bytes): Pointer { return null; }
}
