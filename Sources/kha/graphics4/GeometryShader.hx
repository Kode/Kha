package kha.graphics4;

import kha.Blob;

#if cpp
extern class GeometryShader {
	public function new(sources: Array<Blob>);
	public function delete(): Void;
}
#else
class GeometryShader {
	public function new(sources: Array<Blob>) {}

	public function delete(): Void {}
}
#end
