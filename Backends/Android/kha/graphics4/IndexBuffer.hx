package kha.graphics4;

import android.opengl.GLES20;
import java.NativeArray;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.IntBuffer;
import java.nio.ShortBuffer;
import kha.graphics4.Usage;

class IndexBuffer {
	//private var buffer: Int;
	private var lockedData: Array<Int>;
	public var data: ShortBuffer;
	private var mySize: Int;
	private var usage: Usage;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		mySize = indexCount;
		//buffer = createBuffer();
		lockedData = new Array<Int>();
		lockedData[indexCount - 1] = 0;
		data = ByteBuffer.allocateDirect(indexCount * 2).order(ByteOrder.nativeOrder()).asShortBuffer();
	}
	
	private static function createBuffer(): Int {
		var buffers = new NativeArray<Int>(1);
		GLES20.glGenBuffers(1, buffers, 0);
		return buffers[0];
	}
	
	public function lock(): Array<Int> {
		return lockedData;
	}
	
	public function unlock(): Void {
		for (i in 0...mySize) {
			data.put(i, lockedData[i]);
		}
		//GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, buffer);
		//GLES20.glBufferData(GLES20.GL_ELEMENT_ARRAY_BUFFER, mySize, data, GLES20.GL_STATIC_DRAW);
	}
	
	public function set(): Void {
		//GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, buffer);
	}
	
	public function count(): Int {
		return mySize;
	}
}
