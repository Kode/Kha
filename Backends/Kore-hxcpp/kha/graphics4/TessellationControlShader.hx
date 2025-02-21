package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode("
#include <kinc/graphics4/shader.h>
")
@:headerClassCode("kinc_g4_shader_t shader;")
class TessellationControlShader {
	public function new(sources: Array<Blob>, files: Array<String>) {
		init(sources[0], files[0]);
	}

	function init(source: Blob, file: String): Void {
		untyped __cpp__("kinc_g4_shader_init(&shader, source->bytes->b->Pointer(), source->get_length(), KINC_G4_SHADER_TYPE_TESSELLATION_CONTROL);");
	}

	public function delete(): Void {
		untyped __cpp__("kinc_g4_shader_destroy(&shader);");
	}

	@:keep
	function _forceInclude(): Void {
		Bytes.alloc(0);
	}
}
