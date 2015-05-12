package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexElement;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Program* program;")
class Program {
	public function new() {
		init();
	}
	
	@:functionCode('
		program = new Kore::Program();
	')
	private function init(): Void {
		
	}
	
	public function setVertexShader(shader: VertexShader): Void {
		setVertexShaderImpl(shader);
	}
	
	@:functionCode('
		program->setVertexShader(shader->shader);
	')
	private function setVertexShaderImpl(shader: VertexShader): Void {
		
	}
	
	public function setFragmentShader(shader: FragmentShader): Void {
		setFragmentShaderImpl(shader);
	}
	
	@:functionCode('
		program->setFragmentShader(shader->shader);
	')
	private function setFragmentShaderImpl(shader: FragmentShader): Void {
		
	}
	
	@:functionCode('
		Kore::VertexStructure structure2;
		for (int i = 0; i < structure->size(); ++i) {
			Kore::VertexData data;
			switch (structure->get(i)->data->index) {
			case 0:
				data = Kore::Float1VertexData;
				break;
			case 1:
				data = Kore::Float2VertexData;
				break;
			case 2:
				data = Kore::Float3VertexData;
				break;
			case 3:
				data = Kore::Float4VertexData;
				break;
			}
			structure2.add(structure->get(i)->name, data);
		}
		program->link(structure2);
	')
	public function link(structure: VertexStructure): Void {
		
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		var location = new kha.kore.graphics4.ConstantLocation();
		initConstantLocation(location, name);
		return location;
	}
	
	@:functionCode('
		location->location = program->getConstantLocation(name.c_str());
	')
	private function initConstantLocation(location: kha.kore.graphics4.ConstantLocation, name: String): Void {
		
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var unit = new kha.kore.graphics4.TextureUnit();
		initTextureUnit(unit, name);
		return unit;
	}
	
	@:functionCode('
		unit->unit = program->getTextureUnit(name.c_str());
	')
	private function initTextureUnit(unit: kha.kore.graphics4.TextureUnit, name: String): Void {
		
	}
		
	@:functionCode('
		program->set();
	')
	public function set(): Void {
		
	}
	
	public function unused(): Void {
		var include: VertexElement = new VertexElement("include", VertexData.Float2);
	}
}
