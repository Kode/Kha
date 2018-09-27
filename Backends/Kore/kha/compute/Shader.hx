package kha.compute;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Compute/Compute.h>
')

@:headerClassCode("Kore::ComputeShader* shader;")
class Shader {
	public function new(sources: Array<Blob>, files: Array<String>) {
		init(sources[0], files[0]);
	}
	
	private function init(source: Blob, file: String): Void {
		untyped __cpp__('shader = new Kore::ComputeShader(source->bytes->b->Pointer(), source->get_length());');
	}
	
	public function delete(): Void {
		untyped __cpp__('delete shader; shader = nullptr;');
	}
	
	public function getConstantLocation(name: String): ConstantLocation {
		var location = new ConstantLocation();
		initConstantLocation(location, name);
		return location;
	}
	
	@:functionCode('
		location->location = shader->getConstantLocation(name.c_str());
	')
	private function initConstantLocation(location: ConstantLocation, name: String): Void {
		
	}
	
	public function getTextureUnit(name: String): TextureUnit {
		var unit = new TextureUnit();
		initTextureUnit(unit, name);
		return unit;
	}
	
	@:functionCode('
		unit->unit = shader->getTextureUnit(name.c_str());
	')
	private function initTextureUnit(unit: TextureUnit, name: String): Void {
		
	}

	@:keep
	function _forceInclude(): Void {
		Bytes.alloc(0);
	}
}
