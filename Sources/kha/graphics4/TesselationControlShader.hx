package kha.graphics4;

import kha.Blob;

#if cpp
extern class TesselationControlShader {
	public function new(source: Blob);
}
#else
class TesselationControlShader {
	public function new(source: Blob) {
		
	}
}
#end
