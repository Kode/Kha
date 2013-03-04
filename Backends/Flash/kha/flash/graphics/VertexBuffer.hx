package kha.flash.graphics;

import flash.display3D.VertexBuffer3D;
import flash.Vector;

class VertexBuffer implements kha.graphics.VertexBuffer {
	public var vertexBuffer: VertexBuffer3D;
	private var vertices: Vector<Float>;
	private var lockedVertices: Array<Float>;
	private var vertexCount: Int;
	private var myStride: Int;
	
	public function new(vertexCount: Int, structure: kha.graphics.VertexStructure) {
		this.vertexCount = vertexCount;
		myStride = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case VertexData.Float2:
				myStride += 2;
			case VertexData.Float3:
				myStride += 3;
			}
		}
		vertexBuffer = Graphics.context.createVertexBuffer(vertexCount, myStride);
		vertices = new Vector<Float>(myStride * vertexCount);
		lockedVertices = new Array<Float>();
		lockedVertices[myStride * vertexCount - 1] = 0;
	}
	
	public function lock(?start: Int, ?count: Int): Array<Float> {
		return lockedVertices;
	}
	
	public function unlock(): Void {
		for (i in 0...vertices.length) {
			vertices[i] = lockedVertices[i];
		}
		vertexBuffer.uploadFromVector(vertices, 0, vertexCount);
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function size(): Int {
		return vertexCount;
	}
}
