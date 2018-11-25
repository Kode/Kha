package kha.graphics4;

import kha.Blob;

class GeometryShader {
	public var _shader: Pointer;
	
	public function new(sources: Array<Blob>, files: Array<String>) {
		initShader(sources[0]);
	}
	
	private function initShader(source: Blob): Void {
		_shader = kore_create_geometryshader(source.bytes.getData(), source.bytes.getData().length); 
	}

	public static function fromSource(source: String): GeometryShader {
		var sh = new GeometryShader(null, null);
		sh._shader = kore_geometryshader_from_source(StringHelper.convert(source));
		return sh;
	}

	public function delete(): Void {
		
	}
	
	@:hlNative("std", "kore_create_geometryshader") static function kore_create_geometryshader(data: hl.Bytes, length: Int): Pointer { return null; }
	@:hlNative("std", "kore_geometryshader_from_source") static function kore_geometryshader_from_source(source: hl.Bytes): Pointer { return null; }
}
