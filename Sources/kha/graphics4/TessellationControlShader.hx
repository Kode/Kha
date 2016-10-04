package kha.graphics4;

import kha.Blob;

#if cpp
extern class TessellationControlShader {
	public function new(source: Blob, file: String);
	public function delete();
}
#else
class TessellationControlShader {
	public function new(source: Blob, file: String) {
		
	}
	
	public function delete(): Void {
		
	}
}
#end
