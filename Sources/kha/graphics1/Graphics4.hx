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
	private var pipeline: PipelineState;
	
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
		this.pipeline = pipeline;
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
		var vertexShaderSource = "output.gl_Position = new vec4(input.pos.x,input.pos.y,0.5,1.0);";
		var vertexShader = untyped __js__("new Function([\"input\", \"output\", \"vec4\"], vertexShaderSource)");
		
		var fragmentShaderSource = "output.gl_FragColor = new vec4(1.0, 0.0, 0.0, 1.0);";
		var fragmentShader = untyped __js__("new Function([\"input\", \"output\", \"vec4\"], fragmentShaderSource)");
		
		var index = 0;
		while (index < indexBuffer._data.length) {
			var indices = [indexBuffer._data[index + 0], indexBuffer._data[index + 1], indexBuffer._data[index + 2]];
			
			var layout = pipeline.inputLayout[0];
			
			var vertexStride = Std.int(layout.byteSize() / 4);
			var offsets = [indices[0] * vertexStride, indices[1] * vertexStride, indices[2] * vertexStride];
			
			var vsinputs = new Array<Dynamic>();
			for (index in 0...3) {
				var vsinput: Dynamic = {};
				var vindex = 0;
				for (element in layout.elements) {
					switch (element.data) {
						case VertexData.Float1:
							var data1 = vertexBuffer._data.get(offsets[index] + vindex + 0);
							untyped vsinput[element.name] = data1;
							vindex += 1;
						case VertexData.Float2:
							var data2 = new FastVector2(
								vertexBuffer._data.get(offsets[index] + vindex + 0),
								vertexBuffer._data.get(offsets[index] + vindex + 1));
							untyped vsinput[element.name] = data2;
							vindex += 2;
						case VertexData.Float3:
							var data3 = new FastVector3(
								vertexBuffer._data.get(offsets[index] + vindex + 0),
								vertexBuffer._data.get(offsets[index] + vindex + 1),
								vertexBuffer._data.get(offsets[index] + vindex + 2));
							untyped vsinput[element.name] = data3;
							vindex += 3;
						case VertexData.Float4:
							var data4 = new FastVector4(
								vertexBuffer._data.get(offsets[index] + vindex + 0),
								vertexBuffer._data.get(offsets[index] + vindex + 1),
								vertexBuffer._data.get(offsets[index] + vindex + 2),
								vertexBuffer._data.get(offsets[index] + vindex + 3));
							untyped vsinput[element.name] = data4;
							vindex += 4;
						case VertexData.Float4x4:
							
					}
				}
				vsinputs.push(vsinput);
			}

			var vsoutputs: Array<Dynamic> = [{}, {}, {}, {}];
			for (i in 0...3) vertexShader(vsinputs[i], vsoutputs[i], FastVector4);
			var positions: Array<FastVector4> = [vsoutputs[0].gl_Position, vsoutputs[1].gl_Position, vsoutputs[2].gl_Position];
			
			var minx = min(positions[0].x, positions[1].x, positions[2].x);
			var maxx = max(positions[0].x, positions[1].x, positions[2].x);
			var miny = min(positions[0].y, positions[1].y, positions[2].y);
			var maxy = max(positions[0].y, positions[1].y, positions[2].y);
			
			var minxp = xtopixel(minx);
			var maxxp = xtopixel(maxx);
			var minyp = ytopixel(miny);
			var maxyp = ytopixel(maxy);
			
			for (y in minyp...maxyp) for (x in minxp...maxxp) {
				var bc_screen: FastVector3 = barycentric(
					xtopixel(positions[0].x), ytopixel(positions[0].y),
					xtopixel(positions[1].x), ytopixel(positions[1].y),
					xtopixel(positions[2].x), ytopixel(positions[2].y), x, y);
				if (bc_screen.x < 0 || bc_screen.y < 0 || bc_screen.z < 0) continue;
				var fsoutput: Dynamic = {};
				fragmentShader({}, fsoutput, FastVector4);
				var color: FastVector4 = fsoutput.gl_FragColor;
				g1.setPixel(x, y, Color.fromFloats(color.z, color.y, color.x, color.w));
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
