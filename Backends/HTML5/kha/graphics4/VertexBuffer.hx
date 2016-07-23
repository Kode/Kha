package kha.graphics4;

import js.html.webgl.GL;
import kha.arrays.Float32Array;
import kha.graphics4.Usage;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class VertexBuffer {
	private var buffer: Dynamic;
	private var data: Float32Array;
	private var mySize: Int;
	private var myStride: Int;
	private var sizes: Array<Int>;
	private var offsets: Array<Int>;
	private var usage: Usage;
	private var instanceDataStepRate: Int;
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, instanceDataStepRate: Int = 0, canRead: Bool = false) {
		this.usage = usage;
		this.instanceDataStepRate = instanceDataStepRate;
		mySize = vertexCount;
		myStride = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case Float1:
				myStride += 4 * 1;
			case Float2:
				myStride += 4 * 2;
			case Float3:
				myStride += 4 * 3;
			case Float4:
				myStride += 4 * 4;
			case Float4x4:
				myStride += 4 * 4 * 4;
			}
		}
	
		buffer = SystemImpl.gl.createBuffer();
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
			case Float1:
				size = 1;
			case Float2:
				size = 2;
			case Float3:
				size = 3;
			case Float4:
				size = 4;
			case Float4x4:
				size = 4 * 4;
			}
			sizes[index] = size;
			offsets[index] = offset;
			switch (element.data) {
			case Float1:
				offset += 4 * 1;
			case Float2:
				offset += 4 * 2;
			case Float3:
				offset += 4 * 3;
			case Float4:
				offset += 4 * 4;
			case Float4x4:
				offset += 4 * 4 * 4;
			}
			++index;
		}
	}

	public function delete(): Void {
		data = null;
		SystemImpl.gl.deleteBuffer(buffer);
	}
	
	public function lock(?start: Int, ?count: Int): Float32Array {
		return data;
	}
	
	public function unlock(): Void {
		SystemImpl.gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
		SystemImpl.gl.bufferData(GL.ARRAY_BUFFER, cast data, usage == Usage.DynamicUsage ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function count(): Int {
		return mySize;
	}
	
	public function set(offset: Int): Int {
		var ext: Dynamic = SystemImpl.gl.getExtension("ANGLE_instanced_arrays");
		SystemImpl.gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
		var attributesOffset = 0;
		for (i in 0...sizes.length) {
			if (sizes[i] > 4) {
				var size = sizes[i];
				var addonOffset = 0;
				while (size > 0) {
					SystemImpl.gl.enableVertexAttribArray(offset + attributesOffset);
					SystemImpl.gl.vertexAttribPointer(offset + attributesOffset, 4, GL.FLOAT, false, myStride, offsets[i] + addonOffset);
					if (ext) {
						ext.vertexAttribDivisorANGLE(offset + attributesOffset, instanceDataStepRate);
					}
					size -= 4;
					addonOffset += 4 * 4;
					++attributesOffset;
				}
			}
			else {
				SystemImpl.gl.enableVertexAttribArray(offset + attributesOffset);
				SystemImpl.gl.vertexAttribPointer(offset + attributesOffset, sizes[i], GL.FLOAT, false, myStride, offsets[i]);
				if (ext) {
					ext.vertexAttribDivisorANGLE(offset + attributesOffset, instanceDataStepRate);
				}
				++attributesOffset;
			}
		}
		return attributesOffset;
	}
}
