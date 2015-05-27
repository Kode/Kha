package sce.playstation.core.graphics;

@:native("Sce.PlayStation.Core.Graphics.Texture2D")
extern class Texture2D {
	public function new(filename: String, unknown: Bool);
	public var Width: Int;
	public var Height: Int;
}
