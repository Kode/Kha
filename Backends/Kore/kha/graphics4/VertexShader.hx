package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

@:headerClassCode("Kore::Shader* shader;")
class VertexShader {
	private var source: Blob;
	
	public function new(source: Blob) {
		this.source = source;
		initVertexShader();
		cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(destroy));
	}
	
	@:void private static function destroy(shader: VertexShader): Void {
		untyped __cpp__('delete shader->shader;');
	}
	
	@:functionCode("
		shader = new Kore::Shader(source->bytes->b->Pointer(), source->get_length(), Kore::VertexShader);
	")
	private function initVertexShader(): Void {
		
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
}
