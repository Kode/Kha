package kha.graphics4;

import haxe.io.Float32Array;
import kha.graphics4.Usage;

class ArrayBuffer {
	private var buffer: Dynamic;
	private var data: Float32Array;
	private var mySize: Int;
	private var structureSize: Int;
	private var structureCount: Int;
	private var usage: Usage;
	
	public function new(indexCount: Int, structureSize: Int, structureCount: Int, usage: Usage) {
		this.usage = usage;
		this.structureSize = structureSize;
		this.structureCount = structureCount;
		mySize = indexCount;
		buffer = Sys.gl.createBuffer();
		data = new Float32Array(indexCount);
	}
	
	public function lock(): Float32Array {
		return data;
	}
	
	public function unlock(): Void {
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
		Sys.gl.bufferData(Sys.gl.ARRAY_BUFFER, data, usage == Usage.DynamicUsage ? Sys.gl.DYNAMIC_DRAW : Sys.gl.STATIC_DRAW);
	}
	
	public function set(location : AttributeLocation, divisor : Int): Void {
		var ext : Dynamic = Sys.gl.getExtension("ANGLE_instanced_arrays");
		var locationID : Dynamic = cast(location, kha.js.graphics4.AttributeLocation).value;
		
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
		for (i in 0...structureCount) {
			Sys.gl.enableVertexAttribArray(locationID + i);
			Sys.gl.vertexAttribPointer(locationID + i, structureSize, Sys.gl.FLOAT, false, 4 * structureSize * structureCount, i * 4 * structureSize);
			
			if (ext) {
				ext.vertexAttribDivisorANGLE(locationID + i, divisor);
			}
		}
	}
	
	public function count(): Int {
		return mySize;
	}
}
