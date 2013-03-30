package kha.cpp.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexData;
import kha.graphics.VertexElement;
import kha.graphics.VertexShader;
import kha.graphics.VertexStructure;
import kha.graphics.VertexType;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Graphics.h>
')

@:headerClassCode("Kt::Program* program;")
class Program implements kha.graphics.Program {
	public function new() {
		init();
		
		var a: VertexElement = new VertexElement("a", VertexData.Float2, VertexType.Color); //to generate include
	}
	
	@:functionCode('
		program = Kt::Graphics::createProgram();
	')
	private function init(): Void {
		
	}
	
	public function setVertexShader(shader: VertexShader): Void {
		setVertexShaderImpl(cast(shader, Shader));
	}
	
	@:functionCode('
		program->setVertexShader(shader->shader);
	')
	private function setVertexShaderImpl(shader: Shader): Void {
		
	}
	
	public function setFragmentShader(shader: FragmentShader): Void {
		setFragmentShaderImpl(cast(shader, Shader));
	}
	
	@:functionCode('
		program->setFragmentShader(shader->shader);
	')
	private function setFragmentShaderImpl(shader: Shader): Void {
		
	}
	
	@:functionCode('
		Kt::VertexStructure structure2;
		for (int i = 0; i < structure->elements->size(); ++i) {
			Kt::VertexData data;
			switch (structure->elements[i]->data->index) {
			case 0:
				data = Kt::Float2VertexData;
				break;
			case 1:
				data = Kt::Float3VertexData;
				break;
			}
			Kt::VertexType type;
			switch (structure->elements[i]->type->index) {
			case 0:
				type = Kt::PositionVertexType;
				break;
			case 1:
				type = Kt::ColorVertexType;
				break;
			case 2:
				type = Kt::TexCoordVertexType;
				break;
			}
			structure2.add(Kt::Text(structure->elements[i]->name), data, type);
		}
		program->link(structure2);
	')
	public function link(structure: VertexStructure): Void {
		
	}
	
	@:functionCode('
		return program->getConstantLocation(name.c_str());
	')
	public function getConstantLocation(name: String): Int {
		return 0;
	}
	
	@:functionCode('
		program->set();
	')
	public function set(): Void {
		
	}
}
