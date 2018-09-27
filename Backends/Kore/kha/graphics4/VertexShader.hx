package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
')

@:headerClassCode("Kore::Graphics4::Shader* shader;")
class VertexShader {
	public function new(sources: Array<Blob>, files: Array<String>) {
		if (sources != null) {
			init(sources[0], files[0]);
		}
	}
	
	private function init(source: Blob, file: String): Void {
		untyped __cpp__('shader = new Kore::Graphics4::Shader(source->bytes->b->Pointer(), source->get_length(), Kore::Graphics4::VertexShader);');
	}

	public static function fromSource(source: String): VertexShader {
		var vertexShader = new VertexShader(null, null);
		untyped __cpp__('vertexShader->shader = new Kore::Graphics4::Shader(source, Kore::Graphics4::VertexShader);');
		return vertexShader;
	}
	
	public function delete(): Void {
		untyped __cpp__('delete shader; shader = nullptr;');
	}

	@:keep
	function _forceInclude(): Void {
		Bytes.alloc(0);
	}
}
