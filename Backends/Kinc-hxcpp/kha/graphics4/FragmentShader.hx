package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode("
#include <kinc/graphics4/shader.h>
")
@:headerClassCode("kinc_g4_shader_t shader;")
class FragmentShader {
	public function new(sources: Array<Blob>, files: Array<String>) {
		if (sources != null) {
			init(sources[0], files[0]);
		}
	}

	function init(source: Blob, file: String): Void {
		untyped __cpp__("kinc_g4_shader_init(&shader, source->bytes->b->Pointer(), source->get_length(), KINC_G4_SHADER_TYPE_FRAGMENT);");
	}

	public static function fromSource(source: String): FragmentShader {
		var fragmentShader = new FragmentShader(null, null);
		untyped __cpp__("kinc_g4_shader_init_from_source(&fragmentShader->shader, source, KINC_G4_SHADER_TYPE_FRAGMENT);");
		return fragmentShader;
	}

	public function delete(): Void {
		untyped __cpp__("kinc_g4_shader_destroy(&shader);");
	}

	@:keep
	function _forceInclude(): Void {
		Bytes.alloc(0);
	}
}
