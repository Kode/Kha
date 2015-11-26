package kha.graphics4;

class PipelineState extends PipelineStateBase {
	public function new() {
		super();
	}
	
	public function compile(): Void { }
	
	public function getConstantLocation(name: String): ConstantLocation { return null;  }
	public function getTextureUnit(name: String): TextureUnit { return null;  }
}
