package kha.graphics4;

import kha.Blob;

class VertexShader {
	public var _shader: Pointer;

	public function new(sources: Array<Blob>, files: Array<String>) {
		initShader(sources[0]);
	}

	function initShader(source: Blob): Void {
		_shader = kinc_create_vertexshader(source.bytes.getData(), source.bytes.getData().length);
	}

	public static function fromSource(source: String): VertexShader {
		var sh = new VertexShader(null, null);
		sh._shader = kinc_vertexshader_from_source(StringHelper.convert(source));
		return sh;
	}

	public function delete(): Void {}

	@:hlNative("std", "kinc_create_vertexshader") static function kinc_create_vertexshader(data: hl.Bytes, length: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_vertexshader_from_source") static function kinc_vertexshader_from_source(source: hl.Bytes): Pointer {
		return null;
	}
}
