package kha.graphics4;

import cs.NativeArray;
import haxe.io.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexData;
import sce.playstation.core.graphics.VertexFormat;

class VertexBuffer {
	public var buffer: sce.playstation.core.graphics.VertexBuffer;
	private var indexCount: Int = -1;
	private var myStride: Int;
	private var myStructure: kha.graphics4.VertexStructure;
	private var vertexCount: Int;
	private var vertices: NativeArray<Single>;
	private var lockedVertices: Float32Array;
	
	public function new(vertexCount: Int, structure: kha.graphics4.VertexStructure, usage: Usage) {
		this.vertexCount = vertexCount;
		this.myStructure = structure;
		myStride = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case VertexData.Float1:
				myStride += 1;
			case VertexData.Float2:
				myStride += 2;
			case VertexData.Float3:
				myStride += 3;
			case VertexData.Float4:
				myStride += 4;
			}
		}
		vertices = new NativeArray<Single>(stride() * count());
		lockedVertices = new Float32Array(stride() * count());
	}
	
	public function lock(?start: Int, ?count: Int): Float32Array {
		return lockedVertices;
	}
	
	public function unlock(): Void {
		for (i in 0...stride() * count()) {
			vertices[i] = lockedVertices[i];
		}
		/*var offset = 0;
		var index = 0;
		for (element in myStructure.elements) {
			switch (element.data) {
			case VertexData.Float1:
				buffer.SetVertices(index, vertices, offset * 4, stride() * 4);
				offset += 1;
			case VertexData.Float2:
				buffer.SetVertices(index, vertices, offset * 4, stride() * 4);
				offset += 2;
			case VertexData.Float3:
				buffer.SetVertices(index, vertices, offset * 4, stride() * 4);
				offset += 3;
			case VertexData.Float4:
				buffer.SetVertices(index, vertices, offset * 4, stride() * 4);
				offset += 4;
			}
			++index;
		}*/
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function count(): Int {
		return vertexCount;
	}
	
	private function createVertexBuffer(): Void {
		var format = new NativeArray<VertexFormat>(myStructure.elements.length);
		var index = 0;
		for (element in myStructure.elements) {
			switch (element.data) {
			case VertexData.Float1:
				format[index] = VertexFormat.Float;
			case VertexData.Float2:
				format[index] = VertexFormat.Float2;
			case VertexData.Float3:
				format[index] = VertexFormat.Float3;
			case VertexData.Float4:
				format[index] = VertexFormat.Float4;
			}
			++index;
		}
		buffer = new sce.playstation.core.graphics.VertexBuffer(vertexCount, indexCount, format);
	}
	
	public function setIndices(indexBuffer: IndexBuffer): Void {
		if (indexCount != indexBuffer.count()) {
			indexCount = indexBuffer.count();
			createVertexBuffer();
		}
		buffer.SetIndices(indexBuffer.buffer);
		buffer.SetVertices(vertices);
	}
}
