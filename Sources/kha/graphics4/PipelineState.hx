package kha.graphics4;

extern class PipelineState extends PipelineStateBase {
	public function new();
	public function delete(): Void;
	public function compile(): Void;
	public function getConstantLocation(name: String): ConstantLocation;
	public function getTextureUnit(name: String): TextureUnit;
}
