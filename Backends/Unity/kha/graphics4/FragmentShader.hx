package kha.graphics4;

import kha.Blob;
import unityEngine.Material;
import unityEngine.Shader;

class FragmentShader {
	public var material: Material;
	
	public function new(source: Blob) {
		material = new Material(Shader.Find("Custom/painter-image.frag"));
	}
}
