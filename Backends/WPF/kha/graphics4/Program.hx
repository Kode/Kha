package kha.graphics4;

class Program {
	public function new() { }
	public function setVertexShader(shader: VertexShader): Void { }
	public function setFragmentShader(shader: FragmentShader): Void { }
	public function link(structure: VertexStructure): Void { }
	
	public function getConstantLocation(name: String): ConstantLocation { return null;  }
	public function getTextureUnit(name: String): TextureUnit { return null;  }
}
