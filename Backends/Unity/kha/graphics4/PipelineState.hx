package kha.graphics4;

import unityEngine.Material;
import unityEngine.Shader;

class PipelineState extends PipelineStateBase {
	public var material: Material;
	
	public function new() {
		super();
	}
	
	public function compile(): Void {
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
