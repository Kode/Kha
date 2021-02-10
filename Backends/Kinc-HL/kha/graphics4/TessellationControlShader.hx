package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

class TessellationControlShader {
	public var _shader: Pointer;
	
	public function new(sources: Array<Blob>, files: Array<String>) {
		initShader(sources[0]);
	}
	
	private function initShader(source: Blob): Void {
		_shader = kore_create_tesscontrolshader(source.bytes.getData(), source.bytes.getData().length); 
	}

	public static function fromSource(source: String): TessellationControlShader {
		var sh = new TessellationControlShader(null, null);
		sh._shader = kore_tesscontrolshader_from_source(StringHelper.convert(source));
		return sh;
	}

	public function delete(): Void {
		
	}
	
	@:hlNative("std", "kore_create_tesscontrolshader") static function kore_create_tesscontrolshader(data: hl.Bytes, length: Int): Pointer { return null; }
	@:hlNative("std", "kore_tesscontrolshader_from_source") static function kore_tesscontrolshader_from_source(source: hl.Bytes): Pointer { return null; }
}
