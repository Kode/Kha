package kha.graphics4;

import cs.NativeArray;
import kha.graphics4.Usage;
import kha.graphics4.VertexData;
import sce.playstation.core.graphics.VertexFormat;

class VertexBuffer {
	public var buffer: sce.playstation.core.graphics.VertexBuffer;
	private var myStride: Int;
	private var myStructure: kha.graphics4.VertexStructure;
	private var vertexCount: Int;
	private var vertices: NativeArray<Single>;
	private var lockedVertices: Array<Float>;
	
	public function new(vertexCount: Int, structure: kha.graphics4.VertexStructure, usage: Usage) {
		this.vertexCount = vertexCount;
		this.myStructure = structure;
		myStride = 0;
		var format = new NativeArray<VertexFormat>(structure.elements.length);
		var index = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case VertexData.Float1:
				myStride += 1;
				format[index] = VertexFormat.Float;
			case VertexData.Float2:
				myStride += 2;
				format[index] = VertexFormat.Float2;
			case VertexData.Float3:
				myStride += 3;
				format[index] = VertexFormat.Float3;
			case VertexData.Float4:
				myStride += 4;
				format[index] = VertexFormat.Float4;
			}
		}
		buffer = new sce.playstation.core.graphics.VertexBuffer(vertexCount, format);// (4, 6, Sce.PlayStation.Core.Graphics.VertexFormat.Float3, Sce.PlayStation.Core.Graphics.VertexFormat.Float2, Sce.PlayStation.Core.Graphics.VertexFormat.Float4);
		vertices = new NativeArray<Single>(stride() * count());
		lockedVertices = new Array<Float>();
		lockedVertices[stride() * count() - 1] = 0;
	}
	
	public function lock(?start: Int, ?count: Int): Array<Float> {
		return lockedVertices;
	}
	
	public function unlock(): Void {
		for (i in 0...stride() * count()) {
			vertices[i] = lockedVertices[i];
		}
		var offset = 0;
		var index = 0;
		for (element in myStructure.elements) {
			switch (element.data) {
			case VertexData.Float1:
				buffer.SetVertices(index, vertices, offset, stride());
				offset += 1;
			case VertexData.Float2:
				buffer.SetVertices(index, vertices, offset, stride());
				offset += 2;
			case VertexData.Float3:
				buffer.SetVertices(index, vertices, offset, stride());
				offset += 3;
			case VertexData.Float4:
				buffer.SetVertices(index, vertices, offset, stride());
				offset += 4;
			}
			++index;
		}
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function count(): Int {
		return vertexCount;
	}
}
