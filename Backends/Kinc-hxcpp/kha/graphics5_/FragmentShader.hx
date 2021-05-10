package kha.graphics5;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode('
#include <Kore/Graphics5/Graphics.h>
')

@:headerClassCode("Kore::Graphics5::Shader* shader;")
class FragmentShader {
	public function new(sources: Array<Blob>, files: Array<String>) {
		if (sources != null) {
			init(sources[0], files[0]);
		}
	}
	
	private function init(source: Blob, file: String): Void {
		untyped __cpp__('shader = new Kore::Graphics5::Shader(source->bytes->b->Pointer(), source->get_length(), Kore::Graphics5::FragmentShader);');
	}

	// public static function fromSource(source: String): FragmentShader {
		// var fragmentShader = new FragmentShader(null, null);
		// untyped __cpp__('fragmentShader->shader = new Kore::Graphics5::Shader(source, Kore::Graphics5::FragmentShader);');
		// return fragmentShader;
	// }
	
	public function delete(): Void {
		untyped __cpp__('delete shader; shader = nullptr;');
	}

	@:keep
	function _forceInclude(): Void {
		Bytes.alloc(0);
	}
}
