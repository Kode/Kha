package kha.graphics4;

extern class Program {
	public function new();
	public function setVertexShader(shader: VertexShader): Void;
	public function setFragmentShader(shader: FragmentShader): Void;
	public function link(structure: VertexStructure, instancedStructure: VertexStructure = null): Void;
	
	public function getConstantLocation(name: String): ConstantLocation;
	public function getAttributeLocation(name: String): AttributeLocation;
	public function getTextureUnit(name: String): TextureUnit;
}
