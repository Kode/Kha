package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

//@:headerClassCode("Kore::Shader* shader;")
class VertexShader {
	public function new(source: Blob) {
		initVertexShader(source);
	}
	
	//@:functionCode("shader = new Kore::Shader(source->bytes->b->Pointer(), source->get_length(), Kore::VertexShader);")
	private function initVertexShader(source: Blob): Void {
		
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
}
