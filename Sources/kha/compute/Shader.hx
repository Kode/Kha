package kha.compute;

import kha.Blob;

extern class Shader {
	public function new(sources: Array<Blob>, files: Array<String>);
	public function delete(): Void;
	public function getConstantLocation(name: String): ConstantLocation;
	public function getTextureUnit(name: String): TextureUnit;
}
