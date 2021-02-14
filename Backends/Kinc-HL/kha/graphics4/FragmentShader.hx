package kha.graphics4;

import kha.Blob;

class FragmentShader {
	public var _shader: Pointer;

	public function new(sources: Array<Blob>, files: Array<String>) {
		initShader(sources[0]);
	}

	function initShader(source: Blob): Void {
		_shader = kore_create_fragmentshader(source.bytes.getData(), source.bytes.getData().length);
	}

	public static function fromSource(source: String): FragmentShader {
		var sh = new FragmentShader(null, null);
		sh._shader = kore_fragmentshader_from_source(StringHelper.convert(source));
		return sh;
	}

	public function delete(): Void {}

	@:hlNative("std", "kore_create_fragmentshader") static function kore_create_fragmentshader(data: hl.Bytes, length: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kore_fragmentshader_from_source") static function kore_fragmentshader_from_source(source: hl.Bytes): Pointer {
		return null;
	}
}
