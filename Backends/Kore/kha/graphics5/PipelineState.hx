package kha.graphics5;

class PipelineState extends PipelineStateBase {
	public function new() {
		super();
	}
	
	public function delete(): Void {

	}
	
	private function linkWithStructures2(structure0: VertexStructure, structure1: VertexStructure, structure2: VertexStructure, structure3: VertexStructure, size: Int): Void {
		
	}
	
	public function compile(): Void {
		setStates(cullMode.getIndex(), depthMode.getIndex(), stencilMode.getIndex(), stencilBothPass.getIndex(), stencilDepthFail.getIndex(), stencilFail.getIndex(),
		getBlendFunc(blendSource), getBlendFunc(blendDestination), getBlendFunc(alphaBlendSource), getBlendFunc(alphaBlendDestination));
		linkWithStructures2(
			inputLayout.length > 0 ? inputLayout[0] : null,
			inputLayout.length > 1 ? inputLayout[1] : null,
			inputLayout.length > 2 ? inputLayout[2] : null,
			inputLayout.length > 3 ? inputLayout[3] : null,
			inputLayout.length);
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		var location = new kha.kore.graphics4.ConstantLocation();
		initConstantLocation(location, name);
		return location;
	}
	
	private function initConstantLocation(location: kha.kore.graphics4.ConstantLocation, name: String): Void {
		
	}
		
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var unit = new kha.kore.graphics4.TextureUnit();
		initTextureUnit(unit, name);
		return unit;
	}
	
	private function initTextureUnit(unit: kha.kore.graphics4.TextureUnit, name: String): Void {
		
	}
	
	private static function getBlendFunc(factor: BlendingFactor): Int {
		switch (factor) {
		case BlendOne, Undefined:
			return 0;
		case BlendZero:
			return 1;
		case SourceAlpha:
			return 2;
		case DestinationAlpha:
			return 3;
		case InverseSourceAlpha:
			return 4;
		case InverseDestinationAlpha:
			return 5;
		case SourceColor:
			return 6;
		case DestinationColor:
			return 7;
		case InverseSourceColor:
			return 8;
		case InverseDestinationColor:
			return 9;
		default:
			return 0;
		}
	}
	
	private function setStates(cullMode: Int, depthMode: Int, stencilMode: Int, stencilBothPass: Int, stencilDepthFail: Int, stencilFail: Int,
	blendSource: Int, blendDestination: Int, alphaBlendSource: Int, alphaBlendDestination: Int): Void {
		
	}
	
	private function set2(): Void {
		
	}
	
	public function set(): Void {
		set2();
	}
}
