package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Shader* shader;")
class FragmentShader {
	public function new(source: Blob) {
		initFragmentShader(source);
	}
	
	@:functionCode("
		shader = new Kore::Shader(source->toBytes()->b->Pointer(), source->length(), Kore::FragmentShader);
	")
	private function initFragmentShader(source: Blob): Void {
		
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
}
