package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
')

@:cppFileCode('
#ifndef INCLUDED_haxe_io_Bytes
#include <haxe/io/Bytes.h>
#endif
')

@:headerClassCode("Kore::Graphics4::Shader* shader;")
class TessellationControlShader {
	public function new(sources: Array<Blob>, files: Array<String>) {
		init(sources[0], files[0]);
	}
	
	private function init(source: Blob, file: String): Void {
		untyped __cpp__('shader = new Kore::Graphics4::Shader(source->bytes->b->Pointer(), source->get_length(), Kore::Graphics4::TessellationControlShader);');
	}
	
	public function delete(): Void {
		untyped __cpp__('delete shader; shader = nullptr;');
	}
}
