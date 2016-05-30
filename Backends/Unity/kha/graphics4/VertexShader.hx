package kha.graphics4;

import kha.Blob;

class VertexShader {
	public var name: String;
	
	public function new(source: Blob, file: String) {
		name = source.toString();
	}
}
