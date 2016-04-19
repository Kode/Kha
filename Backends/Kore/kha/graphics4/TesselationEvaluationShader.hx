package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Shader* shader;")
class TesselationEvaluationShader {
	public function new(source: Blob) {
		unused();
		initTesselationEvaluationShader(source);
		//cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(destroy)); // TODO
	}
	
	@:void private static function destroy(shader: TesselationEvaluationShader): Void {
		untyped __cpp__('delete shader->shader;');
	}
	
	@:functionCode("
		shader = new Kore::Shader(source->bytes->b->Pointer(), source->get_length(), Kore::TesselationEvaluationShader);
	")
	private function initTesselationEvaluationShader(source: Blob): Void {
		
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
}
