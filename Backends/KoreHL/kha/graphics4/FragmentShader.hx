package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

class FragmentShader {
	public var _shader: Pointer;
	
	public function new(source: Blob) {
		initFragmentShader(source);
	}
	
	private function initFragmentShader(source: Blob): Void {
		_shader = kore_create_fragmentshader(source.bytes.getData().b, source.bytes.getData().length); 
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
	
	@:hlNative("std", "kore_create_fragmentshader") static function kore_create_fragmentshader(data: hl.types.Bytes, length: Int): Pointer { return null; }
}
