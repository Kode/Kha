package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Shader* shader;")
class VertexShader {
	public function new(source: Blob) {
		initVertexShader(source);
		cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(destroy));
	}
	
	@:void private static function destroy(shader: VertexShader): Void {
		untyped __cpp__('delete shader->shader;');
	}
	
	@:functionCode("
		shader = new Kore::Shader(source->bytes->b->Pointer(), source->get_length(), Kore::VertexShader);
	")
	private function initVertexShader(source: Blob): Void {
		
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
}
