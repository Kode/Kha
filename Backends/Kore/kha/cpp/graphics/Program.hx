package kha.cpp.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexData;
import kha.graphics.VertexElement;
import kha.graphics.VertexShader;
import kha.graphics.VertexStructure;
import kha.graphics.VertexType;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Program* program;")
class Program implements kha.graphics.Program {
	public function new() {
		init();
	}
	
	@:functionCode('
		program = new Kore::Program();
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
		Kore::VertexStructure structure2;
		for (int i = 0; i < structure->size(); ++i) {
			Kore::VertexData data;
			switch (structure->get(i)->data->index) {
			case 0:
				data = Kore::Float2VertexData;
				break;
			case 1:
				data = Kore::Float3VertexData;
				break;
			}
			structure2.add(structure->get(i)->name, data);
		}
		program->link(structure2);
	')
	public function link(structure: VertexStructure): Void {
		
	}
	
	public function getConstantLocation(name: String): kha.graphics.ConstantLocation {
		var location = new ConstantLocation();
		initConstantLocation(location, name);
		return location;
	}
	
	@:functionCode('
		location->location = program->getConstantLocation(name.c_str());
	')
	private function initConstantLocation(location: ConstantLocation, name: String): Void {
		
	}
	
	public function getTextureUnit(name: String): kha.graphics.TextureUnit {
		var unit = new TextureUnit();
		initTextureUnit(unit, name);
		return unit;
	}
	
	@:functionCode('
		unit->unit = program->getTextureUnit(name.c_str());
	')
	private function initTextureUnit(unit: TextureUnit, name: String): Void {
		
	}
		
	@:functionCode('
		program->set();
	')
	public function set(): Void {
		
	}
	
	public function unused(): Void {
		var include: VertexElement = new VertexElement("include", VertexData.Float2, VertexType.Color);
	}
}
