package kha.cpp.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Shader.h>
')

@:headerClassCode("Kt::Shader* shader;")
class Shader implements VertexShader, implements FragmentShader {
	public function new(source: String, type: Dynamic) {
		
	}
	
	public function setInt(name: String, value: Int): Void {
		
	}
	
	public function setFloat(name: String, value: Float): Void {
		
	}
	
	public function setFloat2(name: String, value1: Float, value2: Float): Void {
		
	}
	
	public function setFloat3(name: String, value1: Float, value2: Float, value3: Float): Void {
		
	}
}