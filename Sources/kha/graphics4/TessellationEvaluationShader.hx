package kha.graphics4;

import kha.Blob;

#if cpp
extern class TessellationEvaluationShader {
	public function new(source: Blob, file: String);
	public function delete(): Void;
}
#else
class TessellationEvaluationShader {
	public function new(source: Blob, file: String) {}
	public function delete(): Void {}
}
#end
