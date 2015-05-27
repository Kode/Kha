package sce.playstation.core.graphics;

@:native("Sce.PlayStation.Core.Graphics.ShaderProgram")
extern class ShaderProgram {
	public function new(fileName: String);
	public function FindUniform(name: String): Int;
}
