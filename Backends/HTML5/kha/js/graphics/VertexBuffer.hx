package kha.js.graphics;

class VertexBuffer implements kha.graphics.VertexBuffer {
	private var buffer: Dynamic;
	private var data: Array<Float>;
	private var mySize: Int;
	private var myStride: Int;
	
	public function new(vertexCount: Int, stride: Int) {
		mySize = vertexCount;
		myStride = stride;
		buffer = Sys.gl.createBuffer();
		data = new Array<Float>();
		++vertexCount; //evil hack - browser stride bug?
		data[Std.int(vertexCount * stride / 4) - 1] = 0;
	}
	
	public function lock(?start: Int, ?count: Int): Array<Float> {
		return data;
	}
	
	public function unlock(): Void {
		bind();
		Sys.gl.bufferData(Sys.gl.ARRAY_BUFFER, new Float32Array(data), Sys.gl.STATIC_DRAW);
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function size(): Int {
		return mySize;
	}
	
	public function bind(): Void {
		Sys.gl.bindBuffer(Sys.gl.ARRAY_BUFFER, buffer);
	}
}