package kha.graphics4;

class Program {
	private var vertexShader: VertexShader;
	public var fragmentShader: FragmentShader;
	
	public function new() {
		
	}
	
	public function setVertexShader(shader: VertexShader): Void {
		this.vertexShader = shader;
	}

	public function setFragmentShader(shader: FragmentShader): Void {
		this.fragmentShader = shader;
	}

	public function link(structure: VertexStructure): Void {
		
	}
	
	public function getConstantLocation(name: String): ConstantLocation {
		return new kha.unity.ConstantLocation(name);
	}

	public function getTextureUnit(name: String): TextureUnit {
		return new kha.unity.TextureUnit(name);
	}
}
