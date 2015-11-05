package kha.graphics4;

import unityEngine.Material;
import unityEngine.Shader;

class Program {
	private var vertexShader: VertexShader;
	public var fragmentShader: FragmentShader;
	public var material: Material;
	
	public function new() {
		
	}
	
	public function setVertexShader(shader: VertexShader): Void {
		this.vertexShader = shader;
	}

	public function setFragmentShader(shader: FragmentShader): Void {
		this.fragmentShader = shader;
	}

	public function link(structure: VertexStructure): Void {
		material = new Material(Shader.Find("Custom/" + vertexShader.name + "." + fragmentShader.name));
	}
	
	public function getConstantLocation(name: String): ConstantLocation {
		return new kha.unity.ConstantLocation(name);
	}

	public function getTextureUnit(name: String): TextureUnit {
		return new kha.unity.TextureUnit(name);
	}
	/*
	public function getAttributeLocation(name: String): kha.graphics4.AttributeLocation {
		return null;
	}
	*/
}
