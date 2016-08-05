package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	public function new() {
		super();
	}
	
	public function delete(): Void {
		
	}
		
	public function compile(): Void {
		
	}
	
	public function set(): Void {
		
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return new kha.js.graphics4.ConstantLocation();
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		return new kha.js.graphics4.TextureUnit();
	}
}
