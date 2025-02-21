package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode("
#include <kinc/graphics4/compute.h>
")
@:headerClassCode("kinc_g4_compute_shader shader;")
class ComputeShader {
	public function new(sources: Array<Blob>, files: Array<String>) {
		init(sources[0], files[0]);
	}

	function init(source: Blob, file: String): Void {
		untyped __cpp__("kinc_g4_compute_shader_init(&shader, source->bytes->b->Pointer(), source->get_length());");
	}

	public function delete(): Void {
		untyped __cpp__("kinc_g4_compute_shader_destroy(&shader);");
	}

	public function getConstantLocation(name: String): ConstantLocation {
		var location = new kha.kore.graphics4.ConstantLocation();
		initConstantLocation(location, name);
		return location;
	}

	@:functionCode("location->location = kinc_g4_compute_shader_get_constant_location(&shader, name.c_str());")
	function initConstantLocation(location: kha.kore.graphics4.ConstantLocation, name: String): Void {}

	public function getTextureUnit(name: String): TextureUnit {
		var unit = new kha.kore.graphics4.TextureUnit();
		initTextureUnit(unit, name);
		return unit;
	}

	@:functionCode("unit->unit = kinc_g4_compute_shader_get_texture_unit(&shader, name.c_str());")
	function initTextureUnit(unit: kha.kore.graphics4.TextureUnit, name: String): Void {}

	@:keep
	function _forceInclude(): Void {
		Bytes.alloc(0);
	}
}
