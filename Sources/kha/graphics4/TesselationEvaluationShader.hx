package kha.graphics4;

import kha.Blob;

#if cpp
extern class TesselationEvaluationShader {
	public function new(source: Blob);
}
#else
class TesselationEvaluationShader {
	public function new(source: Blob) {
		
	}
}
#end
