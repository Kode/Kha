package kha.compute;

import haxe.io.Bytes;
import kha.Blob;

class Shader {
	public var shader_: Dynamic;

	public function new(sources: Array<Blob>, files: Array<String>) {
		shader_ = Krom.createShaderCompute(sources[0].toBytes().getData());
	}

	public function delete(): Void {
		Krom.deleteShaderCompute(shader_);
		shader_ = null;
	}

	public function getConstantLocation(name: String): ConstantLocation {
		return Krom.getConstantLocationCompute(shader_, name);
	}

	public function getTextureUnit(name: String): TextureUnit {
		return Krom.getTextureUnitCompute(shader_, name);
	}
}
