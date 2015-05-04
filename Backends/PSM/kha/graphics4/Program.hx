package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

using StringTools;

class Program {
	private var fragmentShader: FragmentShader;
	private var vertexShader: VertexShader;
	
	public function new() {
		
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
		return null;
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		return null;
	}
	
	public function set(): Void {
		
	}
}
