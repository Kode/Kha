package kha.graphics4;

import kha.Blob;

class TessellationEvaluationShader {
	public var _shader: Pointer;

	public function new(sources: Array<Blob>, files: Array<String>) {
		initShader(sources[0]);
	}

	function initShader(source: Blob): Void {
		_shader = kore_create_tessevalshader(source.bytes.getData(), source.bytes.getData().length);
	}

	public static function fromSource(source: String): TessellationEvaluationShader {
		var sh = new TessellationEvaluationShader(null, null);
		sh._shader = kore_tessevalshader_from_source(StringHelper.convert(source));
		return sh;
	}

	public function delete(): Void {}

	@:hlNative("std", "kore_create_tessevalshader") static function kore_create_tessevalshader(data: hl.Bytes, length: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kore_tessevalshader_from_source") static function kore_tessevalshader_from_source(source: hl.Bytes): Pointer {
		return null;
	}
}
