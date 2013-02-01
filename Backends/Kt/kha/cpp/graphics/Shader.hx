package kha.cpp.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Shader.h>
')

@:headerClassCode("Kt::Shader* shader;")
class Shader implements VertexShader, implements FragmentShader {
	public function new(source: String, type: ShaderType) {
		if (type == ShaderType.FragmentShader) initFragmentShader(source);
		else initVertexShader(source);
	}
	
	@:functionCode("
		shader = new Kt::Shader(Kt::Text(source), Kt::VertexShader);
	")
	private function initVertexShader(source: String): Void {
		
	}
	
	@:functionCode("
		shader = new Kt::Shader(Kt::Text(source), Kt::FragmentShader);
	")
	private function initFragmentShader(source: String): Void {
		
	}
	
	@:functionCode("
		shader->assign(Kt::Text(name), value);
	")
	public function setInt(name: String, value: Int): Void {
		
	}
	
	@:functionCode("
		shader->assign(Kt::Text(name), scast<float>(value));
	")
	public function setFloat(name: String, value: Float): Void {
		
	}
	
	@:functionCode("
		float values[2];
		values[0] = value1;
		values[1] = value2;
		shader->assign(Kt::Text(name), values, 2);
	")
	public function setFloat2(name: String, value1: Float, value2: Float): Void {
		
	}
	
	@:functionCode("
		float values[3];
		values[0] = value1;
		values[1] = value2;
		values[2] = value3;
		shader->assign(Kt::Text(name), values, 3);
	")
	public function setFloat3(name: String, value1: Float, value2: Float, value3: Float): Void {
		
	}
}