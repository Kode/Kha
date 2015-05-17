package sce.playstation.core.graphics;

import cs.NativeArray;
import cs.types.UInt16;

@:native("Sce.PlayStation.Core.Graphics.VertexBuffer")
extern class VertexBuffer {
	public function new(vertexCount: Int, indexCount: Int, formats: NativeArray<VertexFormat>);
	public function SetIndices(indices: NativeArray<UInt16>): Void;
	//public function SetVertices(stream: Int, vertices: NativeArray<Single>): Void;
	//public function SetVertices(stream: Int, vertices: NativeArray<Single>, offset: Int, stride: Int): Void;
	public function SetVertices(vertices: NativeArray<Single>): Void;
}
