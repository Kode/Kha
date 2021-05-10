package kha.compute;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode("
#include <kinc/compute/compute.h>
")
@:headerClassCode("kinc_compute_shader shader;")
class Shader {
	public function new(sources: Array<Blob>, files: Array<String>) {
		init(sources[0], files[0]);
	}

	function init(source: Blob, file: String): Void {
		untyped __cpp__("kinc_compute_shader_init(&shader, source->bytes->b->Pointer(), source->get_length());");
	}

	public function delete(): Void {
		untyped __cpp__("kinc_compute_shader_destroy(&shader);");
	}

	public function getConstantLocation(name: String): ConstantLocation {
		var location = new ConstantLocation();
		initConstantLocation(location, name);
		return location;
	}

	@:functionCode("location->location = kinc_compute_shader_get_constant_location(&shader, name.c_str());")
	function initConstantLocation(location: ConstantLocation, name: String): Void {}

	public function getTextureUnit(name: String): TextureUnit {
		var unit = new TextureUnit();
		initTextureUnit(unit, name);
		return unit;
	}

	@:functionCode("unit->unit = kinc_compute_shader_get_texture_unit(&shader, name.c_str());")
	function initTextureUnit(unit: TextureUnit, name: String): Void {}

	@:keep
	function _forceInclude(): Void {
		Bytes.alloc(0);
	}
}
