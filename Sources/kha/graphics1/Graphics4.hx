package kha.graphics1;

import haxe.ds.Vector;
import kha.Blob;
import kha.Color;
import kha.FastFloat;
import kha.Image;
import kha.graphics4.*;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.Video;

class Graphics4 implements kha.graphics4.Graphics {
	private var canvas: Canvas;
	private var g1: kha.graphics1.Graphics;
	private var indexBuffer: IndexBuffer;
	private var vertexBuffer: VertexBuffer;
	
	public function new(canvas: Canvas) {
		this.canvas = canvas;
	}
    
	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		this.g1 = canvas.g1;
		g1.begin();
	}

	public function end(): Void {
		g1.end();
	}
	
	public function vsynced(): Bool {
		return true;
	}

	public function refreshRate(): Int {
		return 60;
	}
	
	public function clear(?color: Color, ?depth: Float, ?stencil: Int): Void {
		
	}

	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {
		
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		
	}
	
	public function disableScissor(): Void {
		
	}

	public function setVertexBuffer(vertexBuffer: VertexBuffer): Void {
		this.vertexBuffer = vertexBuffer;
	}

	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
		
	}

	public function setIndexBuffer(indexBuffer: IndexBuffer): Void {
		this.indexBuffer = indexBuffer;
	}
	
	public function setTexture(unit: TextureUnit, texture: Image): Void {
		
	}

	public function setVideoTexture(unit: TextureUnit, texture: Video): Void {
		
	}

	public function setTextureParameters(texunit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		
	}

	public function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap {
		return null;
	}
	
	public function renderTargetsInvertedY(): Bool {
		return false;
	}

	public function instancedRenderingAvailable(): Bool {
		return false;
	}
	
	public function setPipeline(pipeline: PipelineState): Void {
		
	}
	
	public function setBool(location: ConstantLocation, value: Bool): Void {
		
	}

	public function setInt(location: ConstantLocation, value: Int): Void {
		
	}

	public function setFloat(location: ConstantLocation, value: FastFloat): Void {
		
	}

	public function setFloat2(location: ConstantLocation, value1: FastFloat, value2: FastFloat): Void {
		
	}

	public function setFloat3(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat): Void {
		
	}
	
	public function setFloat4(location: ConstantLocation, value1: FastFloat, value2: FastFloat, value3: FastFloat, value4: FastFloat): Void {
		
	}
	
	public function setFloats(location: ConstantLocation, floats: Vector<FastFloat>): Void {
		
	}
	
	public function setVector2(location: ConstantLocation, value: FastVector2): Void {
		
	}

	public function setVector3(location: ConstantLocation, value: FastVector3): Void {
		
	}
	
	public function setVector4(location: ConstantLocation, value: FastVector4): Void {
		
	}
	
	public function setMatrix(location: ConstantLocation, value: FastMatrix4): Void {
		
	}
	
	private static inline function min(a: FastFloat, b: FastFloat, c: FastFloat): FastFloat {
		var min1 = a < b ? a : b;
		return min1 < c ? min1 : c;
	}
	
	private static inline function max(a: FastFloat, b: FastFloat, c: FastFloat): FastFloat {
		var max1 = a > b ? a : b;
		return max1 > c ? max1 : c;
	}
	
	private inline function xtopixel(x: FastFloat): Int {
		return Std.int((x + 1) / 2 * canvas.width);
	}
	
	private inline function ytopixel(y: FastFloat): Int {
		return Std.int((y + 1) / 2 * canvas.height);
	}
	
	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		var index = 0;
		while (index < indexBuffer._data.length) {
			var _1index = indexBuffer._data[index + 0];
			var _2index = indexBuffer._data[index + 1];
			var _3index = indexBuffer._data[index + 2];
			
			var vertexStride = 3;
			var _1offset = _1index * vertexStride;
			var _2offset = _2index * vertexStride;
			var _3offset = _3index * vertexStride;
			
			var _1: FastVector3 = new FastVector3(vertexBuffer._data.get(_1offset + 0), vertexBuffer._data.get(_1offset + 1), vertexBuffer._data.get(_1offset + 2));
			var _2: FastVector3 = new FastVector3(vertexBuffer._data.get(_2offset + 0), vertexBuffer._data.get(_2offset + 1), vertexBuffer._data.get(_2offset + 2));
			var _3: FastVector3 = new FastVector3(vertexBuffer._data.get(_3offset + 0), vertexBuffer._data.get(_3offset + 1), vertexBuffer._data.get(_3offset + 2));

			var minx = min(_1.x, _2.x, _3.x);
			var maxx = max(_1.x, _2.x, _3.x);
			var miny = min(_1.y, _2.y, _3.y);
			var maxy = max(_1.y, _2.y, _3.y);
			
			var minxp = xtopixel(minx);
			var maxxp = xtopixel(maxx);
			var minyp = ytopixel(miny);
			var maxyp = ytopixel(maxy);
			
			//for (y in minyp...maxyp) for (x in minxp...maxxp)
			//	g1.setPixel(x, y, Color.Red);
			
			for (y in minyp...maxyp) for (x in minxp...maxxp) {
				var bc_screen: FastVector3 = barycentric(xtopixel(_1.x), ytopixel(_1.y), xtopixel(_2.x), ytopixel(_2.y), xtopixel(_3.x), ytopixel(_3.y), x, y);
				if (bc_screen.x < 0 || bc_screen.y < 0 || bc_screen.z < 0) continue;
				g1.setPixel(x, y, Color.Red);
			}
			
			index += 3;
		}
	}
	
	private static inline function barycentric(_1x: Int, _1y: Int, _2x: Int, _2y: Int, _3x: Int, _3y: Int, x: Int, y: Int): FastVector3 {
		var a = new FastVector3(_3x - _1x, _2x - _1x, _1x - x);
		var b = new FastVector3(_3y - _1y, _2y - _1y, _1y - y);
		var u: FastVector3 = a.cross(b);
		if (Math.abs(u.z) < 1) return new FastVector3(-1, 1, 1); // degenerate 
		return new FastVector3(1.0 - (u.x + u.y) / u.z, u.y / u.z, u.x / u.z); 
	}

	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {
		
	}
	
	public function flush(): Void {
		
	}
}
