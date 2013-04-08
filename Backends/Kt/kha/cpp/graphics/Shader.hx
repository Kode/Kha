package kha.cpp.graphics;

import haxe.io.Bytes;
import kha.Blob;
import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Graphics.h>
')

@:headerClassCode("Kt::Shader* shader;")
class Shader implements VertexShader, implements FragmentShader {
	public function new(source: Blob, type: ShaderType) {
		if (type == ShaderType.FragmentShader) initFragmentShader(source);
		else initVertexShader(source);
	}
	
	@:functionCode("
		shader = Kt::Graphics::createVertexShader(source->toBytes()->b->Pointer());
	")
	private function initVertexShader(source: Blob): Void {
		
	}
	
	@:functionCode("
		shader = Kt::Graphics::createFragmentShader(source->toBytes()->b->Pointer());
	")
	private function initFragmentShader(source: Blob): Void {
		
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
}
