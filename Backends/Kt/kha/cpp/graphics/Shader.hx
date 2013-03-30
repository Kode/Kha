package kha.cpp.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Graphics.h>
')

@:headerClassCode("Kt::Shader* shader;")
class Shader implements VertexShader, implements FragmentShader {
	public function new(source: String, type: ShaderType) {
		if (type == ShaderType.FragmentShader) initFragmentShader(source);
		else initVertexShader(source);
	}
	
	@:functionCode("
		shader = Kt::Graphics::createVertexShader(Kt::Text(source));
	")
	private function initVertexShader(source: String): Void {
		
	}
	
	@:functionCode("
		shader = Kt::Graphics::createFragmentShader(Kt::Text(source));
	")
	private function initFragmentShader(source: String): Void {
		
	}
}
