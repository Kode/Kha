package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import sce.playstation.core.graphics.ShaderProgram;

using StringTools;

class Program {
	private var fragmentShader: FragmentShader;
	private var vertexShader: VertexShader;
	public var program: ShaderProgram;
	
	public function new() {
		program = new ShaderProgram("/Application/shaders/Texture.cgx");
	}

	public function setVertexShader(shader: VertexShader): Void {
		vertexShader = shader;
	}

	public function setFragmentShader(shader: FragmentShader): Void {
		fragmentShader = shader;
	}
	
	public function link(structure: VertexStructure): Void {
		
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return new kha.psm.graphics4.ConstantLocation(program.FindUniform(name));
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		return new kha.psm.graphics4.TextureUnit();
	}
}
