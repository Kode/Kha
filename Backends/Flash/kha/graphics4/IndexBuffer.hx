package kha.graphics4;

import flash.display3D.IndexBuffer3D;
import kha.arrays.Uint32Array;
import kha.graphics4.Usage;

class IndexBuffer {
	public static var current: IndexBuffer;

	public var indexBuffer: IndexBuffer3D;

	var indices: Uint32Array;
	var lockedIndices: Uint32Array;

	public function new(indexCount: Int, usage: Usage) {
		indexBuffer = kha.flash.graphics4.Graphics.context.createIndexBuffer(indexCount); // , usage == Usage.DynamicUsage ? "dynamicDraw" : "staticDraw");
		indices = new Uint32Array(indexCount);
		lockedIndices = new Uint32Array(indexCount);
		lockedIndices[indexCount - 1] = 0;
	}

	public function lock(?start: Int, ?count: Int): Uint32Array {
		return lockedIndices;
	}

	public function unlock(?count: Int): Void {
		for (i in 0...indices.length) {
			indices[i] = lockedIndices[i];
		}
		indexBuffer.uploadFromVector(indices, 0, indices.length);
	}

	public function count(): Int {
		return indices.length;
	}

	public function set(): Void {
		current = this;
	}

	public function delete(): Void {
		indexBuffer.dispose();
	}
}
