package kha.cpp.graphics;

import haxe.io.Bytes;
import kha.Blob;
import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Shader* shader;")
class Shader implements VertexShader implements FragmentShader {
	public function new(source: Blob, type: ShaderType) {
		if (type == ShaderType.FragmentShader) initFragmentShader(source);
		else initVertexShader(source);
	}
	
	@:functionCode("
		shader = new Kore::Shader(source->toBytes()->b->Pointer(), source->length(), Kore::VertexShader);
	")
	private function initVertexShader(source: Blob): Void {
		
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
