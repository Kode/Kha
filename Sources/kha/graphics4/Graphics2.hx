package kha.graphics4;

import kha.arrays.Float32Array;
import kha.Canvas;
import kha.Color;
import kha.FastFloat;
import kha.Font;
import kha.Image;
import kha.graphics4.BlendingOperation;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CullMode;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.Program;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix3;
import kha.math.FastVector2;
import kha.math.Matrix3;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.simd.Float32x4;

class ImageShaderPainter {
	private var projectionMatrix: Matrix4;
	private var shaderProgram: Program;
	private var structure: VertexStructure;
	private var projectionLocation: ConstantLocation;
	private var textureLocation: TextureUnit;
	private static var bufferSize: Int = 1500;
	private static var vertexSize: Int = 9;
	private var bufferIndex: Int;
	private var rectVertexBuffer: VertexBuffer;
    private var rectVertices: Float32Array;
	private var indexBuffer: IndexBuffer;
	private var lastTexture: Image;
	private var bilinear: Bool = false;
	private var g: Graphics;
	private var myProgram: Program = null;
	public var program(get, set): Program;
	
	public var sourceBlend: BlendingOperation = BlendingOperation.Undefined;
	public var destinationBlend: BlendingOperation = BlendingOperation.Undefined;
	
	public function new(g4: Graphics) {
		this.g = g4;
		bufferIndex = 0;
		initShaders();
		initBuffers();
		projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
		textureLocation = shaderProgram.getTextureUnit("tex");
	}
	
	private function get_program(): Program {
		return myProgram;
	}
	
	private function set_program(prog: Program): Program {
		if (prog == null) {
			projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
			textureLocation = shaderProgram.getTextureUnit("tex");
		}
		else {
			projectionLocation = prog.getConstantLocation("projectionMatrix");
			textureLocation = prog.getTextureUnit("tex");
		}
		return myProgram = prog;
	}
	
	public function setProjection(projectionMatrix: Matrix4): Void {
		this.projectionMatrix = projectionMatrix;
	}
	
	private function initShaders(): Void {
		var fragmentShader = new FragmentShader(Loader.the.getShader("painter-image.frag"));
		var vertexShader = new VertexShader(Loader.the.getShader("painter-image.vert"));
	
		shaderProgram = new Program();
		shaderProgram.setFragmentShader(fragmentShader);
		shaderProgram.setVertexShader(vertexShader);

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		
		shaderProgram.link(structure);
	}
	
	function initBuffers(): Void {
		rectVertexBuffer = new VertexBuffer(bufferSize * 4, structure, Usage.DynamicUsage);
		rectVertices = rectVertexBuffer.lock();
		
		indexBuffer = new IndexBuffer(bufferSize * 3 * 2, Usage.StaticUsage);
		var indices = indexBuffer.lock();
		for (i in 0...bufferSize) {
			indices[i * 3 * 2 + 0] = i * 4 + 0;
			indices[i * 3 * 2 + 1] = i * 4 + 1;
			indices[i * 3 * 2 + 2] = i * 4 + 2;
			indices[i * 3 * 2 + 3] = i * 4 + 0;
			indices[i * 3 * 2 + 4] = i * 4 + 2;
			indices[i * 3 * 2 + 5] = i * 4 + 3;
		}
		indexBuffer.unlock();
	}
	
	private inline function setRectVertices(
		bottomleftx: FastFloat, bottomlefty: FastFloat,
		topleftx: FastFloat, toplefty: FastFloat,
		toprightx: FastFloat, toprighty: FastFloat,
		bottomrightx: FastFloat, bottomrighty: FastFloat): Void {
		var baseIndex: Int = bufferIndex * vertexSize * 4;
		rectVertices.set(baseIndex +  0, bottomleftx);
		rectVertices.set(baseIndex +  1, bottomlefty);
		rectVertices.set(baseIndex +  2, -5.0);
		
		rectVertices.set(baseIndex +  9, topleftx);
		rectVertices.set(baseIndex + 10, toplefty);
		rectVertices.set(baseIndex + 11, -5.0);
		
		rectVertices.set(baseIndex + 18, toprightx);
		rectVertices.set(baseIndex + 19, toprighty);
		rectVertices.set(baseIndex + 20, -5.0);
		
		rectVertices.set(baseIndex + 27, bottomrightx);
		rectVertices.set(baseIndex + 28, bottomrighty);
		rectVertices.set(baseIndex + 29, -5.0);
	}
	
	private inline function setRectTexCoords(left: FastFloat, top: FastFloat, right: FastFloat, bottom: FastFloat): Void {
		var baseIndex: Int = bufferIndex * vertexSize * 4;
		rectVertices.set(baseIndex +  3, left);
		rectVertices.set(baseIndex +  4, bottom);
		
		rectVertices.set(baseIndex + 12, left);
		rectVertices.set(baseIndex + 13, top);
		
		rectVertices.set(baseIndex + 21, right);
		rectVertices.set(baseIndex + 22, top);
		
		rectVertices.set(baseIndex + 30, right);
		rectVertices.set(baseIndex + 31, bottom);
	}
	
	private inline function setRectColor(r: FastFloat, g: FastFloat, b: FastFloat, a: FastFloat): Void {
		var baseIndex: Int = bufferIndex * vertexSize * 4;
		rectVertices.set(baseIndex +  5, r);
		rectVertices.set(baseIndex +  6, g);
		rectVertices.set(baseIndex +  7, b);
		rectVertices.set(baseIndex +  8, a);
		
		rectVertices.set(baseIndex + 14, r);
		rectVertices.set(baseIndex + 15, g);
		rectVertices.set(baseIndex + 16, b);
		rectVertices.set(baseIndex + 17, a);
		
		rectVertices.set(baseIndex + 23, r);
		rectVertices.set(baseIndex + 24, g);
		rectVertices.set(baseIndex + 25, b);
		rectVertices.set(baseIndex + 26, a);
		
		rectVertices.set(baseIndex + 32, r);
		rectVertices.set(baseIndex + 33, g);
		rectVertices.set(baseIndex + 34, b);
		rectVertices.set(baseIndex + 35, a);
	}

	private function drawBuffer(): Void {
		rectVertexBuffer.unlock();
		g.setVertexBuffer(rectVertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.setProgram(program == null ? shaderProgram : program);
		g.setTexture(textureLocation, lastTexture);
		g.setTextureParameters(textureLocation, TextureAddressing.Clamp, TextureAddressing.Clamp, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, MipMapFilter.NoMipFilter);
		g.setMatrix(projectionLocation, projectionMatrix);
		if (sourceBlend == BlendingOperation.Undefined || destinationBlend == BlendingOperation.Undefined) {
			g.setBlendingMode(BlendingOperation.BlendOne, BlendingOperation.InverseSourceAlpha);
		}
		else {
			g.setBlendingMode(sourceBlend, destinationBlend);
		}
		
		g.drawIndexedVertices(0, bufferIndex * 2 * 3);

		g.setTexture(textureLocation, null);
		bufferIndex = 0;
		rectVertices = rectVertexBuffer.lock();
	}
	
	public function setBilinearFilter(bilinear: Bool): Void {
		end();
		this.bilinear = bilinear;
	}
	
	public inline function drawImage(img: kha.Image,
		bottomleftx: FastFloat, bottomlefty: FastFloat,
		topleftx: FastFloat, toplefty: FastFloat,
		toprightx: FastFloat, toprighty: FastFloat,
		bottomrightx: FastFloat, bottomrighty: FastFloat,
		opacity: FastFloat, color: Color): Void {
		var tex = img;
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();
		
		setRectColor(color.R, color.G, color.B, opacity);
		setRectTexCoords(0, 0, tex.width / tex.realWidth, tex.height / tex.realHeight);
		setRectVertices(bottomleftx, bottomlefty, topleftx, toplefty, toprightx, toprighty, bottomrightx, bottomrighty);
		
		++bufferIndex;
		lastTexture = tex;
	}
	
	public inline function drawImage2(img: kha.Image, sx: FastFloat, sy: FastFloat, sw: FastFloat, sh: FastFloat,
		bottomleftx: FastFloat, bottomlefty: FastFloat,
		topleftx: FastFloat, toplefty: FastFloat,
		toprightx: FastFloat, toprighty: FastFloat,
		bottomrightx: FastFloat, bottomrighty: FastFloat,
		opacity: FastFloat, color: Color): Void {
		var tex = img;
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();
		
		setRectTexCoords(sx / tex.realWidth, sy / tex.realHeight, (sx + sw) / tex.realWidth, (sy + sh) / tex.realHeight);
		setRectColor(color.R, color.G, color.B, opacity);
		setRectVertices(bottomleftx, bottomlefty, topleftx, toplefty, toprightx, toprighty, bottomrightx, bottomrighty);
		
		++bufferIndex;
		lastTexture = tex;
	}
	
	public inline function drawImageScale(img: kha.Image, sx: FastFloat, sy: FastFloat, sw: FastFloat, sh: FastFloat, left: FastFloat, top: FastFloat, right: FastFloat, bottom: FastFloat, opacity: FastFloat, color: Color): Void {
		var tex = img;
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();
		
		setRectTexCoords(sx / tex.realWidth, sy / tex.realHeight, (sx + sw) / tex.realWidth, (sy + sh) / tex.realHeight);
		setRectColor(color.R, color.G, color.B, opacity);
		setRectVertices(left, bottom, left, top, right, top, right, bottom);
		
		++bufferIndex;
		lastTexture = tex;
	}

	public function end(): Void {
		if (bufferIndex > 0) drawBuffer();
		lastTexture = null;
	}
}

class ColoredShaderPainter {
	private var projectionMatrix: Matrix4;
	private var shaderProgram: Program;
	private var structure: VertexStructure;
	private var projectionLocation: ConstantLocation;
	
	private static var bufferSize: Int = 100;
	private var bufferIndex: Int;
	private var rectVertexBuffer: VertexBuffer;
    private var rectVertices: Float32Array;
	private var indexBuffer: IndexBuffer;
	
	private static var triangleBufferSize: Int = 100;
	private var triangleBufferIndex: Int;
	private var triangleVertexBuffer: VertexBuffer;
    private var triangleVertices: Float32Array;
	private var triangleIndexBuffer: IndexBuffer;
	
	private var g: Graphics;
	private var myProgram: Program = null;
	public var program(get, set): Program;
	
	public var sourceBlend: BlendingOperation = BlendingOperation.Undefined;
	public var destinationBlend: BlendingOperation = BlendingOperation.Undefined;
	
	public function new(g4: Graphics) {
		this.g = g4;
		bufferIndex = 0;
		triangleBufferIndex = 0;
		initShaders();
		initBuffers();
		projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
	}
	
	private function get_program(): Program {
		return myProgram;
	}
	
	private function set_program(prog: Program): Program {
		if (prog == null) {
			projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
		}
		else {
			projectionLocation = prog.getConstantLocation("projectionMatrix");
		}
		return myProgram = prog;
	}
	
	public function setProjection(projectionMatrix: Matrix4): Void {
		this.projectionMatrix = projectionMatrix;
	}
	
	private function initShaders(): Void {
		var fragmentShader = new FragmentShader(Loader.the.getShader("painter-colored.frag"));
		var vertexShader = new VertexShader(Loader.the.getShader("painter-colored.vert"));
	
		shaderProgram = new Program();
		shaderProgram.setFragmentShader(fragmentShader);
		shaderProgram.setVertexShader(vertexShader);

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("vertexColor", VertexData.Float4);
		
		shaderProgram.link(structure);
	}
	
	function initBuffers(): Void {
		rectVertexBuffer = new VertexBuffer(bufferSize * 4, structure, Usage.DynamicUsage);
		rectVertices = rectVertexBuffer.lock();
		
		indexBuffer = new IndexBuffer(bufferSize * 3 * 2, Usage.StaticUsage);
		var indices = indexBuffer.lock();
		for (i in 0...bufferSize) {
			indices[i * 3 * 2 + 0] = i * 4 + 0;
			indices[i * 3 * 2 + 1] = i * 4 + 1;
			indices[i * 3 * 2 + 2] = i * 4 + 2;
			indices[i * 3 * 2 + 3] = i * 4 + 0;
			indices[i * 3 * 2 + 4] = i * 4 + 2;
			indices[i * 3 * 2 + 5] = i * 4 + 3;
		}
		indexBuffer.unlock();
		
		triangleVertexBuffer = new VertexBuffer(triangleBufferSize * 3, structure, Usage.DynamicUsage);
		triangleVertices = triangleVertexBuffer.lock();
		
		triangleIndexBuffer = new IndexBuffer(triangleBufferSize * 3, Usage.StaticUsage);
		var triIndices = triangleIndexBuffer.lock();
		for (i in 0...bufferSize) {
			triIndices[i * 3 + 0] = i * 3 + 0;
			triIndices[i * 3 + 1] = i * 3 + 1;
			triIndices[i * 3 + 2] = i * 3 + 2;
		}
		triangleIndexBuffer.unlock();
	}
	
	public function setRectVertices(
		bottomleftx: Float, bottomlefty: Float,
		topleftx: Float, toplefty: Float,
		toprightx: Float, toprighty: Float,
		bottomrightx: Float, bottomrighty: Float): Void {
		var baseIndex: Int = bufferIndex * 7 * 4;
		rectVertices.set(baseIndex +  0, bottomleftx);
		rectVertices.set(baseIndex +  1, bottomlefty);
		rectVertices.set(baseIndex +  2, -5.0);
		
		rectVertices.set(baseIndex +  7, topleftx);
		rectVertices.set(baseIndex +  8, toplefty);
		rectVertices.set(baseIndex +  9, -5.0);
		
		rectVertices.set(baseIndex + 14, toprightx);
		rectVertices.set(baseIndex + 15, toprighty);
		rectVertices.set(baseIndex + 16, -5.0);
		
		rectVertices.set(baseIndex + 21, bottomrightx);
		rectVertices.set(baseIndex + 22, bottomrighty);
		rectVertices.set(baseIndex + 23, -5.0);
	}
	
	public function setRectColors(color: Color): Void {
		var baseIndex: Int = bufferIndex * 7 * 4;
		rectVertices.set(baseIndex +  3, color.R);
		rectVertices.set(baseIndex +  4, color.G);
		rectVertices.set(baseIndex +  5, color.B);
		rectVertices.set(baseIndex +  6, color.A);
		
		rectVertices.set(baseIndex + 10, color.R);
		rectVertices.set(baseIndex + 11, color.G);
		rectVertices.set(baseIndex + 12, color.B);
		rectVertices.set(baseIndex + 13, color.A);
		
		rectVertices.set(baseIndex + 17, color.R);
		rectVertices.set(baseIndex + 18, color.G);
		rectVertices.set(baseIndex + 19, color.B);
		rectVertices.set(baseIndex + 20, color.A);
		
		rectVertices.set(baseIndex + 24, color.R);
		rectVertices.set(baseIndex + 25, color.G);
		rectVertices.set(baseIndex + 26, color.B);
		rectVertices.set(baseIndex + 27, color.A);
	}
	
	private function setTriVertices(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float): Void {
		var baseIndex: Int = triangleBufferIndex * 7 * 3;
		triangleVertices.set(baseIndex +  0, x1);
		triangleVertices.set(baseIndex +  1, y1);
		triangleVertices.set(baseIndex +  2, -5.0);
		
		triangleVertices.set(baseIndex +  7, x2);
		triangleVertices.set(baseIndex +  8, y2);
		triangleVertices.set(baseIndex +  9, -5.0);
		
		triangleVertices.set(baseIndex + 14, x3);
		triangleVertices.set(baseIndex + 15, y3);
		triangleVertices.set(baseIndex + 16, -5.0);
	}
	
	private function setTriColors(color: Color): Void {
		var baseIndex: Int = triangleBufferIndex * 7 * 3;
		triangleVertices.set(baseIndex +  3, color.R);
		triangleVertices.set(baseIndex +  4, color.G);
		triangleVertices.set(baseIndex +  5, color.B);
		triangleVertices.set(baseIndex +  6, color.A);
		
		triangleVertices.set(baseIndex + 10, color.R);
		triangleVertices.set(baseIndex + 11, color.G);
		triangleVertices.set(baseIndex + 12, color.B);
		triangleVertices.set(baseIndex + 13, color.A);
		
		triangleVertices.set(baseIndex + 17, color.R);
		triangleVertices.set(baseIndex + 18, color.G);
		triangleVertices.set(baseIndex + 19, color.B);
		triangleVertices.set(baseIndex + 20, color.A);
	}

	private function drawBuffer(trisDone: Bool): Void {
		if (!trisDone) endTris(true);
		
		rectVertexBuffer.unlock();
		g.setVertexBuffer(rectVertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.setProgram(program == null ? shaderProgram : program);
		g.setMatrix(projectionLocation, projectionMatrix);
		if (sourceBlend == BlendingOperation.Undefined || destinationBlend == BlendingOperation.Undefined) {
			g.setBlendingMode(BlendingOperation.SourceAlpha, BlendingOperation.InverseSourceAlpha);
		}
		else {
			g.setBlendingMode(sourceBlend, destinationBlend);
		}
		
		g.drawIndexedVertices(0, bufferIndex * 2 * 3);

		bufferIndex = 0;
		rectVertices = rectVertexBuffer.lock();
	}
	
	private function drawTriBuffer(rectsDone: Bool): Void {
		if (!rectsDone) endRects(true);
		
		triangleVertexBuffer.unlock();
		g.setVertexBuffer(triangleVertexBuffer);
		g.setIndexBuffer(triangleIndexBuffer);
		g.setProgram(program == null ? shaderProgram : program);
		g.setMatrix(projectionLocation, projectionMatrix);
		if (sourceBlend == BlendingOperation.Undefined || destinationBlend == BlendingOperation.Undefined) {
			g.setBlendingMode(BlendingOperation.SourceAlpha, BlendingOperation.InverseSourceAlpha);
		}
		else {
			g.setBlendingMode(sourceBlend, destinationBlend);
		}
		
		g.drawIndexedVertices(0, triangleBufferIndex * 3);

		triangleBufferIndex = 0;
		triangleVertices = triangleVertexBuffer.lock();
	}
	
	public function fillRect(color: Color,
		bottomleftx: Float, bottomlefty: Float,
		topleftx: Float, toplefty: Float,
		toprightx: Float, toprighty: Float,
		bottomrightx: Float, bottomrighty: Float): Void {
		if (bufferIndex + 1 >= bufferSize) drawBuffer(false);
				
		setRectColors(color);
		setRectVertices(bottomleftx, bottomlefty, topleftx, toplefty, toprightx, toprighty, bottomrightx, bottomrighty);
		++bufferIndex;
	}
	
	public function fillTriangle(color: Color, x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		if (triangleBufferIndex + 1 >= triangleBufferSize) drawTriBuffer(false);
		
		setTriColors(color);
		setTriVertices(x1, y1, x2, y2, x3, y3);
		++triangleBufferIndex;
	}
	
	public inline function endTris(rectsDone: Bool): Void {
		if (triangleBufferIndex > 0) drawTriBuffer(rectsDone);
	}
	
	public inline function endRects(trisDone: Bool): Void {
		if (bufferIndex > 0) drawBuffer(trisDone);
	}
	
	public inline function end(): Void {
		endTris(false);
		endRects(false);
	}
}

#if cpp
@:headerClassCode("const wchar_t* wtext;")
#end
class TextShaderPainter {
	private var projectionMatrix: Matrix4;
	private var shaderProgram: Program;
	private var structure: VertexStructure;
	private var projectionLocation: ConstantLocation;
	private var textureLocation: TextureUnit;
	private static var bufferSize: Int = 100;
	private var bufferIndex: Int;
	private var rectVertexBuffer: VertexBuffer;
    private var rectVertices: Float32Array;
	private var indexBuffer: IndexBuffer;
	private var font: Kravur;
	private var lastTexture: Image;
	private var g: Graphics;
	private var myProgram: Program = null;
	public var program(get, set): Program;
	
	public var sourceBlend: BlendingOperation = BlendingOperation.Undefined;
	public var destinationBlend: BlendingOperation = BlendingOperation.Undefined;
	
	public function new(g4: Graphics) {
		this.g = g4;
		bufferIndex = 0;
		initShaders();
		initBuffers();
		projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
		textureLocation = shaderProgram.getTextureUnit("tex");
	}
	
	private function get_program(): Program {
		return myProgram;
	}
	
	private function set_program(prog: Program): Program {
		if (prog == null) {
			projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
			textureLocation = shaderProgram.getTextureUnit("tex");
		}
		else {
			projectionLocation = prog.getConstantLocation("projectionMatrix");
			textureLocation = prog.getTextureUnit("tex");
		}
		return myProgram = prog;
	}
	
	public function setProjection(projectionMatrix: Matrix4): Void {
		this.projectionMatrix = projectionMatrix;
	}
	
	private function initShaders(): Void {
		var fragmentShader = new FragmentShader(Loader.the.getShader("painter-text.frag"));
		var vertexShader = new VertexShader(Loader.the.getShader("painter-text.vert"));
	
		shaderProgram = new Program();
		shaderProgram.setFragmentShader(fragmentShader);
		shaderProgram.setVertexShader(vertexShader);

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		
		shaderProgram.link(structure);
	}
	
	function initBuffers(): Void {
		rectVertexBuffer = new VertexBuffer(bufferSize * 4, structure, Usage.DynamicUsage);
		rectVertices = rectVertexBuffer.lock();
		
		indexBuffer = new IndexBuffer(bufferSize * 3 * 2, Usage.StaticUsage);
		var indices = indexBuffer.lock();
		for (i in 0...bufferSize) {
			indices[i * 3 * 2 + 0] = i * 4 + 0;
			indices[i * 3 * 2 + 1] = i * 4 + 1;
			indices[i * 3 * 2 + 2] = i * 4 + 2;
			indices[i * 3 * 2 + 3] = i * 4 + 0;
			indices[i * 3 * 2 + 4] = i * 4 + 2;
			indices[i * 3 * 2 + 5] = i * 4 + 3;
		}
		indexBuffer.unlock();
	}
	
	private function setRectVertices(
		bottomleftx: Float, bottomlefty: Float,
		topleftx: Float, toplefty: Float,
		toprightx: Float, toprighty: Float,
		bottomrightx: Float, bottomrighty: Float): Void {
		var baseIndex: Int = bufferIndex * 9 * 4;
		rectVertices.set(baseIndex +  0, bottomleftx);
		rectVertices.set(baseIndex +  1, bottomlefty);
		rectVertices.set(baseIndex +  2, -5.0);
		
		rectVertices.set(baseIndex +  9, topleftx);
		rectVertices.set(baseIndex + 10, toplefty);
		rectVertices.set(baseIndex + 11, -5.0);
		
		rectVertices.set(baseIndex + 18, toprightx);
		rectVertices.set(baseIndex + 19, toprighty);
		rectVertices.set(baseIndex + 20, -5.0);
		
		rectVertices.set(baseIndex + 27, bottomrightx);
		rectVertices.set(baseIndex + 28, bottomrighty);
		rectVertices.set(baseIndex + 29, -5.0);
	}
	
	private function setRectTexCoords(left: Float, top: Float, right: Float, bottom: Float): Void {
		var baseIndex: Int = bufferIndex * 9 * 4;
		rectVertices.set(baseIndex +  3, left);
		rectVertices.set(baseIndex +  4, bottom);
		
		rectVertices.set(baseIndex + 12, left);
		rectVertices.set(baseIndex + 13, top);
		
		rectVertices.set(baseIndex + 21, right);
		rectVertices.set(baseIndex + 22, top);
		
		rectVertices.set(baseIndex + 30, right);
		rectVertices.set(baseIndex + 31, bottom);
	}
	
	private function setRectColors(color: Color): Void {
		var baseIndex: Int = bufferIndex * 9 * 4;
		rectVertices.set(baseIndex +  5, color.R);
		rectVertices.set(baseIndex +  6, color.G);
		rectVertices.set(baseIndex +  7, color.B);
		rectVertices.set(baseIndex +  8, color.A);
		
		rectVertices.set(baseIndex + 14, color.R);
		rectVertices.set(baseIndex + 15, color.G);
		rectVertices.set(baseIndex + 16, color.B);
		rectVertices.set(baseIndex + 17, color.A);
		
		rectVertices.set(baseIndex + 23, color.R);
		rectVertices.set(baseIndex + 24, color.G);
		rectVertices.set(baseIndex + 25, color.B);
		rectVertices.set(baseIndex + 26, color.A);
		
		rectVertices.set(baseIndex + 32, color.R);
		rectVertices.set(baseIndex + 33, color.G);
		rectVertices.set(baseIndex + 34, color.B);
		rectVertices.set(baseIndex + 35, color.A);
	}
	
	private function drawBuffer(): Void {
		rectVertexBuffer.unlock();
		g.setVertexBuffer(rectVertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.setProgram(program == null ? shaderProgram : program);
		g.setTexture(textureLocation, lastTexture);
		g.setMatrix(projectionLocation, projectionMatrix);
		if (sourceBlend == BlendingOperation.Undefined || destinationBlend == BlendingOperation.Undefined) {
			g.setBlendingMode(BlendingOperation.SourceAlpha, BlendingOperation.InverseSourceAlpha);
		}
		else {
			g.setBlendingMode(sourceBlend, destinationBlend);
		}
		
		g.drawIndexedVertices(0, bufferIndex * 2 * 3);

		g.setTexture(textureLocation, null);
		bufferIndex = 0;
		rectVertices = rectVertexBuffer.lock();
	}
	
	public function setFont(font: Font): Void {
		this.font = cast(font, Kravur);
	}
	
	private var text: String;
	
	#if cpp
	@:functionCode('
		wtext = text.__WCStr();
	')
	#end
	private function startString(text: String): Void {
		this.text = text;
	}
	
	#if cpp
	@:functionCode('
		return wtext[position];
	')
	#end
	private function charCodeAt(position: Int): Int {
		return text.charCodeAt(position);
	}
	
	#if cpp
	@:functionCode('
		return wcslen(wtext);
	')
	#end
	private function stringLength(): Int {
		return text.length;
	}
	
	#if cpp
	@:functionCode('
		wtext = 0;
	')
	#end
	private function endString(): Void {
		text = null;
	}
	
	public function drawString(text: String, color: Color, x: Float, y: Float, transformation: FastMatrix3): Void {
		var tex = font.getTexture();
		if (lastTexture != null && tex != lastTexture) drawBuffer();
		lastTexture = tex;

		var xpos = x;
		var ypos = y;
		startString(text);
		for (i in 0...stringLength()) {
			var q = font.getBakedQuad(charCodeAt(i) - 32, xpos, ypos);
			if (q != null) {
				if (bufferIndex + 1 >= bufferSize) drawBuffer();
				setRectColors(color);
				setRectTexCoords(q.s0 * tex.width / tex.realWidth, q.t0 * tex.height / tex.realHeight, q.s1 * tex.width / tex.realWidth, q.t1 * tex.height / tex.realHeight);
				var p0 = transformation.multvec(new FastVector2(q.x0, q.y1)); //bottom-left
				var p1 = transformation.multvec(new FastVector2(q.x0, q.y0)); //top-left
				var p2 = transformation.multvec(new FastVector2(q.x1, q.y0)); //top-right
				var p3 = transformation.multvec(new FastVector2(q.x1, q.y1)); //bottom-right
				setRectVertices(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
				xpos += q.xadvance;
				++bufferIndex;
			}
		}
		endString();
	}
	
	public function end(): Void {
		if (bufferIndex > 0) drawBuffer();
		lastTexture = null;
	}
}

class Graphics2 extends kha.graphics2.Graphics {
	private var myColor: Color;
	private var myFont: Font;
	private var projectionMatrix: Matrix4;
	public var imagePainter: ImageShaderPainter;
	private var coloredPainter: ColoredShaderPainter;
	private var textPainter: TextShaderPainter;
	private var videoProgram: Program;
	private var canvas: Canvas;
	private var g: Graphics;

	public function new(canvas: Canvas) {
		super();
		color = Color.White;
		this.canvas = canvas;
		g = canvas.g4;
		imagePainter = new ImageShaderPainter(g);
		coloredPainter = new ColoredShaderPainter(g);
		textPainter = new TextShaderPainter(g);
		setProjection();
		
		var fragmentShader = new FragmentShader(Loader.the.getShader("painter-video.frag"));
		var vertexShader = new VertexShader(Loader.the.getShader("painter-video.vert"));
	
		videoProgram = new Program();
		videoProgram.setFragmentShader(fragmentShader);
		videoProgram.setVertexShader(vertexShader);

		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		
		videoProgram.link(structure);
	}
	
	private static function upperPowerOfTwo(v: Int): Int {
		v--;
		v |= v >>> 1;
		v |= v >>> 2;
		v |= v >>> 4;
		v |= v >>> 8;
		v |= v >>> 16;
		v++;
		return v;
	}
	
	private function setProjection(): Void {
		var width = canvas.width;
		var height = canvas.height;
		if (Std.is(canvas, Framebuffer)) {
			projectionMatrix = Matrix4.orthogonalProjection(0, width, height, 0, 0.1, 1000);
		} else {
			if (!Image.nonPow2Supported) {
				width = upperPowerOfTwo(width);
				height = upperPowerOfTwo(height);
			}
			if (g.renderTargetsInvertedY()) {
				projectionMatrix = Matrix4.orthogonalProjection(0, width, 0, height, 0.1, 1000);
			} else {
				projectionMatrix = Matrix4.orthogonalProjection(0, width, height, 0, 0.1, 1000);
			}
		}
		imagePainter.setProjection(projectionMatrix);
		coloredPainter.setProjection(projectionMatrix);
		textPainter.setProjection(projectionMatrix);
	}
	
	public override function drawImage(img: kha.Image, x: FastFloat, y: FastFloat): Void {
		coloredPainter.end();
		textPainter.end();
		var xw: FastFloat = x + img.width;
		var yh: FastFloat = y + img.height;
		
		var xx = Float32x4.loadFast(x, x, xw, xw);
		var yy = Float32x4.loadFast(yh, y, y, yh);
		
		var _00 = Float32x4.loadAllFast(transformation._00);
		var _01 = Float32x4.loadAllFast(transformation._01);
		var _02 = Float32x4.loadAllFast(transformation._02);
		var _10 = Float32x4.loadAllFast(transformation._10);
		var _11 = Float32x4.loadAllFast(transformation._11);
		var _12 = Float32x4.loadAllFast(transformation._12);
		var _20 = Float32x4.loadAllFast(transformation._20);
		var _21 = Float32x4.loadAllFast(transformation._21);
		var _22 = Float32x4.loadAllFast(transformation._22);
		
		// matrix multiply
		var w = Float32x4.add(Float32x4.add(Float32x4.mul(_02, xx), Float32x4.mul(_12, yy)), _22);
		var px = Float32x4.div(Float32x4.add(Float32x4.add(Float32x4.mul(_00, xx), Float32x4.mul(_10, yy)), _20), w);
		var py = Float32x4.div(Float32x4.add(Float32x4.add(Float32x4.mul(_01, xx), Float32x4.mul(_11, yy)), _21), w);
		
		imagePainter.drawImage(img, Float32x4.get(px, 0), Float32x4.get(py, 0), Float32x4.get(px, 1), Float32x4.get(py, 1),
			Float32x4.get(px, 2), Float32x4.get(py, 2), Float32x4.get(px, 3), Float32x4.get(py, 3), opacity, this.color);
	}
	
	public override function drawScaledSubImage(img: kha.Image, sx: FastFloat, sy: FastFloat, sw: FastFloat, sh: FastFloat, dx: FastFloat, dy: FastFloat, dw: FastFloat, dh: FastFloat): Void {
		coloredPainter.end();
		textPainter.end();
		var p1 = transformation.multvec(new FastVector2(dx, dy + dh));
		var p2 = transformation.multvec(new FastVector2(dx, dy));
		var p3 = transformation.multvec(new FastVector2(dx + dw, dy));
		var p4 = transformation.multvec(new FastVector2(dx + dw, dy + dh));
		imagePainter.drawImage2(img, sx, sy, sw, sh, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y, opacity, this.color);
	}
	
	override public function get_color(): Color {
		return myColor;
	}
	
	override public function set_color(color: Color): Color {
		return myColor = color;
	}
	
	public override function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0): Void {
		imagePainter.end();
		textPainter.end();
		
		var p1 = transformation.multvec(new FastVector2(x - strength / 2, y + strength / 2)); //bottom-left
		var p2 = transformation.multvec(new FastVector2(x - strength / 2, y - strength / 2)); //top-left
		var p3 = transformation.multvec(new FastVector2(x + width + strength / 2, y - strength / 2)); //top-right
		var p4 = transformation.multvec(new FastVector2(x + width + strength / 2, y + strength / 2)); //bottom-right
		coloredPainter.fillRect(color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y); // top
		
		p1 = transformation.multvec(new FastVector2(x - strength / 2, y + height + strength / 2));
		p3 = transformation.multvec(new FastVector2(x + strength / 2, y - strength / 2));
		p4 = transformation.multvec(new FastVector2(x + strength / 2, y + height + strength / 2));
		coloredPainter.fillRect(color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y); // left
		
		p2 = transformation.multvec(new FastVector2(x - strength / 2, y + height - strength / 2));
		p3 = transformation.multvec(new FastVector2(x + width + strength / 2, y + height - strength / 2));
		p4 = transformation.multvec(new FastVector2(x + width + strength / 2, y + height + strength / 2));
		coloredPainter.fillRect(color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y); // bottom
		
		p1 = transformation.multvec(new FastVector2(x + width - strength / 2, y + height + strength / 2));
		p2 = transformation.multvec(new FastVector2(x + width - strength / 2, y - strength / 2));
		p3 = transformation.multvec(new FastVector2(x + width + strength / 2, y - strength / 2));
		p4 = transformation.multvec(new FastVector2(x + width + strength / 2, y + height + strength / 2));
		coloredPainter.fillRect(color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y); // right
	}
	
	public override function fillRect(x: Float, y: Float, width: Float, height: Float): Void {
		imagePainter.end();
		textPainter.end();
		
		var p1 = transformation.multvec(new FastVector2(x, y + height));
		var p2 = transformation.multvec(new FastVector2(x, y));
		var p3 = transformation.multvec(new FastVector2(x + width, y));
		var p4 = transformation.multvec(new FastVector2(x + width, y + height));
		coloredPainter.fillRect(color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
	}

	public override function drawString(text: String, x: Float, y: Float): Void {
		imagePainter.end();
		coloredPainter.end();
		
		textPainter.drawString(text, color, x, y, transformation);
	}

	override public function get_font(): Font {
		return myFont;
	}
	
	override public function set_font(font: Font): Font {
		textPainter.setFont(font);
		return myFont = font;
	}

	public override function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0): Void {
		imagePainter.end();
		textPainter.end();
		
		var vec: FastVector2;
		if (y2 == y1) vec = new FastVector2(0, -1);
		else vec = new FastVector2(1, -(x2 - x1) / (y2 - y1));
		vec.length = strength;
		var p1 = new FastVector2(x1 + 0.5 * vec.x, y1 + 0.5 * vec.y);
		var p2 = new FastVector2(x2 + 0.5 * vec.x, y2 + 0.5 * vec.y);
		var p3 = p1.sub(vec);
		var p4 = p2.sub(vec);
		
		p1 = transformation.multvec(p1);
		p2 = transformation.multvec(p2);
		p3 = transformation.multvec(p3);
		p4 = transformation.multvec(p4);
		
		coloredPainter.fillTriangle(color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
		coloredPainter.fillTriangle(color, p3.x, p3.y, p2.x, p2.y, p4.x, p4.y);		
	}

	public override function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		imagePainter.end();
		textPainter.end();
		
		var p1 = transformation.multvec(new FastVector2(x1, y1));
		var p2 = transformation.multvec(new FastVector2(x2, y2));
		var p3 = transformation.multvec(new FastVector2(x3, y3));
		coloredPainter.fillTriangle(color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
	}
	
	public function setBilinearFiltering(bilinear: Bool): Void {
		imagePainter.setBilinearFilter(bilinear);
	}
	
	override private function setProgram(program: Program): Void {
		endDrawing();
		imagePainter.program = program;
		coloredPainter.program = program;
		textPainter.program = program;
		if (program != null) g.setProgram(program);
	}
	
	override public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		endDrawing();
		imagePainter.sourceBlend = source;
		imagePainter.destinationBlend = destination;
		coloredPainter.sourceBlend = source;
		coloredPainter.destinationBlend = destination;
		textPainter.sourceBlend = source;
		textPainter.destinationBlend = destination;
	}
	
	public override function begin(clear: Bool = true, clearColor: Color = null): Void {
		g.begin();
		if (clear) this.clear(clearColor);
		setProjection();
		g.setCullMode(CullMode.None);
	}
	
	override public function clear(color: Color = null): Void {
		g.clear(color == null ? Color.Black : color);
	}
	
	private function endDrawing(): Void {
		imagePainter.end();
		textPainter.end();
		coloredPainter.end();
	}
	
	public override function end(): Void {
		endDrawing();
		g.end();
	}
	
	private function drawVideoInternal(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {
		
	}
	
	override public function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {
		setProgram(videoProgram);
		drawVideoInternal(video, x, y, width, height);
		setProgram(null);
	}
}
