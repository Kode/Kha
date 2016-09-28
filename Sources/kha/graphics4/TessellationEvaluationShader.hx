package kha.graphics4;

import kha.Blob;

#if cpp
extern class TessellationEvaluationShader {
	public function new(source: Blob);
	public function delete();
}
#else
class TessellationEvaluationShader {
	public function new(source: Blob) {
		
	}
	
	public function delete(): Void {
		
	}
}
#end
