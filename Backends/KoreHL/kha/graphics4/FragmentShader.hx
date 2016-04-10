package kha.graphics4;

import haxe.io.Bytes;
import kha.Blob;

//@:headerClassCode("Kore::Shader* shader;")
class FragmentShader {
	public function new(source: Blob) {
		initFragmentShader(source);
	}
	
	//@:functionCode("shader = new Kore::Shader(source->bytes->b->Pointer(), source->get_length(), Kore::FragmentShader);")
	private function initFragmentShader(source: Blob): Void {
		
	}
	
	public function unused(): Void {
		var include: Bytes = Bytes.ofString("");
	}
}
