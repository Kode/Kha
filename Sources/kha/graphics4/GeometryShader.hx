package kha.graphics4;

import kha.Blob;

#if cpp
extern class GeometryShader {
	public function new(source: Blob);
}
#else
class GeometryShader {
	public function new(source: Blob) {
		
	}
}
#end
