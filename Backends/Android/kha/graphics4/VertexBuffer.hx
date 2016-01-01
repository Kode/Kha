package kha.graphics4;

import android.opengl.GLES20;
import java.NativeArray;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import kha.arrays.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class VertexBuffer {
	private var buffer: Int;
	private var data: Float32Array;
	private var mySize: Int;
	private var myStride: Int;
	private var sizes: Array<Int>;
	private var offsets: Array<Int>;
	private var usage: Usage;
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		mySize = vertexCount;
		myStride = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case VertexData.Float1:
				myStride += 4 * 1;
			case VertexData.Float2:
				myStride += 4 * 2;
			case VertexData.Float3:
				myStride += 4 * 3;
			case VertexData.Float4:
				myStride += 4 * 4;
			case VertexData.Float4x4:
				myStride += 4 * 4 * 4;
			}
		}
	
		buffer = createBuffer();
		data = new Float32Array(Std.int(vertexCount * myStride / 4));
		
		sizes = new Array<Int>();
		offsets = new Array<Int>();
		sizes[structure.elements.length - 1] = 0;
		offsets[structure.elements.length - 1] = 0;
		
		var offset = 0;
		var index = 0;
		for (element in structure.elements) {
			var size;
			switch (element.data) {
			case VertexData.Float1:
				size = 1;
			case VertexData.Float2:
				size = 2;
			case VertexData.Float3:
				size = 3;
			case VertexData.Float4:
				size = 4;
			case VertexData.Float4x4:
				size = 4 * 4;
			}
			sizes[index] = size;
			offsets[index] = offset;
			switch (element.data) {
			case VertexData.Float1:
				offset += 4 * 1;
			case VertexData.Float2:
				offset += 4 * 2;
			case VertexData.Float3:
				offset += 4 * 3;
			case VertexData.Float4:
				offset += 4 * 4;
			case VertexData.Float4x4:
				offset += 4 * 4 * 4;
			}
			++index;
		}
	}
	
	private static function createBuffer(): Int {
		var buffers = new NativeArray<Int>(1);
		GLES20.glGenBuffers(1, buffers, 0);
		return buffers[0];
	}
	
	public function lock(?start: Int, ?count: Int): Float32Array {
		return data;
	}
	
	public function unlock(): Void {
		GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, buffer);
		GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, mySize * myStride, data.data(), usage == Usage.DynamicUsage ? GLES20.GL_DYNAMIC_DRAW : GLES20.GL_STATIC_DRAW);
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function count(): Int {
		return mySize;
	}
	
	public function set(): Void {
		GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, buffer);
		for (i in 0...sizes.length) {
			GLES20.glEnableVertexAttribArray(i);
			GLES20.glVertexAttribPointer(i, sizes[i], GLES20.GL_FLOAT, false, myStride, offsets[i]);
		}
	}
}
