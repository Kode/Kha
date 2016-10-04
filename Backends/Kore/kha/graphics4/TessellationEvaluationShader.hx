package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:cppFileCode('
#ifndef INCLUDED_haxe_io_Bytes
#include <haxe/io/Bytes.h>
#endif
')

@:headerClassCode("Kore::Shader* shader;")
class TessellationEvaluationShader {
	public function new(source: Blob, file: String) {
		untyped __cpp__('shader = new Kore::Shader(source->bytes->b->Pointer(), source->get_length(), Kore::TessellationEvaluationShader);');
	}
	
	public function delete(): Void {
		untyped __cpp__('delete shader; shader = nullptr;');
	}
}
