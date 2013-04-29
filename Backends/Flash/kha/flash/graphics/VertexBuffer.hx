package kha.flash.graphics;

import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.VertexBuffer3D;
import flash.Vector;
import kha.graphics.VertexData;

class VertexBuffer implements kha.graphics.VertexBuffer {
	public var vertexBuffer: VertexBuffer3D;
	private var vertices: Vector<Float>;
	private var lockedVertices: Array<Float>;
	private var vertexCount: Int;
	private var myStride: Int;
	private var myStructure: kha.graphics.VertexStructure;
	
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
		myStructure = structure;
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
	
	public function count(): Int {
		return vertexCount;
	}
	
	public function set(): Void {
		var index: Int = 0;
		var offset: Int = 0;
		for (element in myStructure.elements) {
			switch (element.data) {
			case VertexData.Float2:
				Graphics.context.setVertexBufferAt(index, vertexBuffer, offset, Context3DVertexBufferFormat.FLOAT_2);
				offset += 2;
			case VertexData.Float3:
				Graphics.context.setVertexBufferAt(index, vertexBuffer, offset, Context3DVertexBufferFormat.FLOAT_3);
				offset += 3;
			}
			++index;
		}
		for (i in index...8) Graphics.context.setVertexBufferAt(i, null);
	}
}
