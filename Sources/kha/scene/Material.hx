package kha.scene;

import kha.Color;
import kha.graphics.Texture;

class Material {
	public function new() {
		ambient = Color.fromBytes(0, 0, 0);
		diffuse = Color.fromBytes(255, 255, 255);
		specular = Color.fromBytes(0, 0, 0);
		emissive = Color.fromBytes(0, 0, 0);
		shininess = 1;
	}

	public var ambient: Color;
	public var diffuse: Color;
	public var specular: Color;
	public var emissive: Color;
	public var shininess: Float;
	public var texture: Texture;
}
