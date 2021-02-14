package kha.graphics4;

import kha.Blob;

#if cpp
extern class TessellationEvaluationShader {
	public function new(sources: Array<Blob>, files: Array<String>);
	public function delete();
}
#else
class TessellationEvaluationShader {
	public function new(sources: Array<Blob>, files: Array<String>) {}

	public function delete(): Void {}
}
#end
