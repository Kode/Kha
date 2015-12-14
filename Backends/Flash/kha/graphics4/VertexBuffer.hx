package kha.graphics4;

import flash.display3D.Context3DBufferUsage;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.VertexBuffer3D;
import flash.Vector;
import kha.arrays.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexData;

class VertexBuffer {
	public var vertexBuffer: VertexBuffer3D;
	private var vertices: Float32Array;
	private var vertexCount: Int;
	private var myStride: Int;
	private var myStructure: kha.graphics4.VertexStructure;
	
	public function new(vertexCount: Int, structure: kha.graphics4.VertexStructure, usage: Usage) {
		this.vertexCount = vertexCount;
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
			case VertexData.Float4x4:
				myStride += 4 * 4;
			}
		}
		myStructure = structure;
		vertexBuffer = kha.flash.graphics4.Graphics.context.createVertexBuffer(vertexCount, myStride, usage == Usage.DynamicUsage ? Context3DBufferUsage.DYNAMIC_DRAW : Context3DBufferUsage.STATIC_DRAW);
		vertices = new Float32Array(myStride * vertexCount);
	}
	
	public function lock(?start: Int, ?count: Int): Float32Array {
		return vertices;
	}
	
	public function unlock(): Void {
		vertexBuffer.uploadFromByteArray(vertices.data(), 0, 0, vertexCount);
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
			case VertexData.Float1:
				kha.flash.graphics4.Graphics.context.setVertexBufferAt(index, vertexBuffer, offset, Context3DVertexBufferFormat.FLOAT_1);
				offset += 1;
				++index;
			case VertexData.Float2:
				kha.flash.graphics4.Graphics.context.setVertexBufferAt(index, vertexBuffer, offset, Context3DVertexBufferFormat.FLOAT_2);
				offset += 2;
				++index;
			case VertexData.Float3:
				kha.flash.graphics4.Graphics.context.setVertexBufferAt(index, vertexBuffer, offset, Context3DVertexBufferFormat.FLOAT_3);
				offset += 3;
				++index;
			case VertexData.Float4:
				kha.flash.graphics4.Graphics.context.setVertexBufferAt(index, vertexBuffer, offset, Context3DVertexBufferFormat.FLOAT_4);
				offset += 4;
				++index;
			case VertexData.Float4x4:
				for (i in 0...4) {
					kha.flash.graphics4.Graphics.context.setVertexBufferAt(index, vertexBuffer, offset, Context3DVertexBufferFormat.FLOAT_4);
					offset += 4;
					++index;
				}
			}
		}
		for (i in index...8) kha.flash.graphics4.Graphics.context.setVertexBufferAt(i, null);
	}
}
