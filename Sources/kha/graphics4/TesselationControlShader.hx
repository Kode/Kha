package kha.graphics4;

import kha.Blob;

#if cpp
extern class TesselationControlShader {
	public function new(source: Blob);
	public function delete();
}
#else
class TesselationControlShader {
	public function new(source: Blob) {
		
	}
	
	public function delete(): Void {
		
	}
}
#end
