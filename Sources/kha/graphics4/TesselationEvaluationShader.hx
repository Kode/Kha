package kha.graphics4;

import kha.Blob;

#if cpp
extern class TesselationEvaluationShader {
	public function new(source: Blob);
	public function delete();
}
#else
class TesselationEvaluationShader {
	public function new(source: Blob) {
		
	}
	
	public function delete(): Void {
		
	}
}
#end
