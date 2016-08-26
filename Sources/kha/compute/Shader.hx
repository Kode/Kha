package kha.compute;

import kha.Blob;

extern class Shader {
	public function new(source: Blob, file: String);
	public function delete(): Void;
	public function getConstantLocation(name: String): ConstantLocation;
	public function getTextureUnit(name: String): TextureUnit;
}
