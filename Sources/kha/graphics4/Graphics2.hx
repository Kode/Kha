package kha.graphics4;

import kha.arrays.Float32Array;
import kha.Canvas;
import kha.Color;
import kha.FastFloat;
import kha.Font;
import kha.graphics2.ImageScaleQuality;
import kha.Image;
import kha.graphics4.BlendingOperation;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CullMode;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.Matrix3;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.Shaders;
import kha.simd.Float32x4;

class PipelineCache {
	public var pipeline: PipelineState;
	public var projectionLocation: ConstantLocation;
	public var textureLocation: TextureUnit;

	public function new(pipeline: PipelineState) {
		this.pipeline = pipeline;
		projectionLocation = pipeline.getConstantLocation("projectionMatrix");
		textureLocation = pipeline.getTextureUnit("tex");
	}
}

class ImageShaderPainter {
	var projectionMatrix: FastMatrix4;
	static var standardImagePipeline: PipelineCache = null;
	static var structure: VertexStructure = null;
	static inline var bufferSize: Int = 1500;
	static inline var vertexSize: Int = 9;
	static var bufferIndex: Int;
	static var rectVertexBuffer: VertexBuffer;
	static var rectVertices: Float32Array;
	static var indexBuffer: IndexBuffer;
	static var lastTexture: Image;
	var bilinear: Bool = false;
	var bilinearMipmaps: Bool = false;
	var g: Graphics;
	var myPipeline: PipelineCache = null;
	public var pipeline(get, set): PipelineCache;

	public function new(g4: Graphics) {
		this.g = g4;
		bufferIndex = 0;
		initShaders();
		myPipeline = standardImagePipeline;
		initBuffers();
	}

	private function get_pipeline(): PipelineCache {
		return myPipeline;
	}

	private function set_pipeline(pipe: PipelineCache): PipelineCache {
		myPipeline = pipe != null ? pipe : standardImagePipeline;
		return myPipeline;
	}

	public function setProjection(projectionMatrix: FastMatrix4): Void {
		this.projectionMatrix = projectionMatrix;
	}

	private static function initShaders(): Void {
		if (structure == null) {
			structure = Graphics2.createImageVertexStructure();
		}
		if (standardImagePipeline == null) {
			var pipeline = Graphics2.createImagePipeline(structure);
			pipeline.compile();
			standardImagePipeline = new PipelineCache(pipeline);
		}
	}

	function initBuffers(): Void {
		if (rectVertexBuffer == null) {
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
		rectVertexBuffer.unlock(bufferIndex * 4);
		g.setVertexBuffer(rectVertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.setPipeline(myPipeline.pipeline);
		g.setTexture(myPipeline.textureLocation, lastTexture);
		g.setTextureParameters(myPipeline.textureLocation, TextureAddressing.Clamp, TextureAddressing.Clamp, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinearMipmaps ? MipMapFilter.LinearMipFilter : MipMapFilter.NoMipFilter);
		g.setMatrix(myPipeline.projectionLocation, projectionMatrix);

		g.drawIndexedVertices(0, bufferIndex * 2 * 3);

		g.setTexture(myPipeline.textureLocation, null);
		bufferIndex = 0;
		rectVertices = rectVertexBuffer.lock();
	}

	public function setBilinearFilter(bilinear: Bool): Void {
		end();
		this.bilinear = bilinear;
	}

	public function setBilinearMipmapFilter(bilinear: Bool): Void {
		end();
		this.bilinearMipmaps = bilinear;
	}

	public inline function drawImage(img: kha.Image,
		bottomleftx: FastFloat, bottomlefty: FastFloat,
		topleftx: FastFloat, toplefty: FastFloat,
		toprightx: FastFloat, toprighty: FastFloat,
		bottomrightx: FastFloat, bottomrighty: FastFloat,
		opacity: FastFloat, color: Color): Void {
		var tex = img;
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();

		setRectColor(color.R, color.G, color.B, color.A * opacity);
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
		setRectColor(color.R, color.G, color.B, color.A * opacity);
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
	var projectionMatrix: FastMatrix4;
	static var standardColorPipeline: PipelineCache = null;
	static var structure: VertexStructure = null;

	static inline var bufferSize: Int = 1000;
	static var bufferIndex: Int;
	static var rectVertexBuffer: VertexBuffer;
	static var rectVertices: Float32Array;
	static var indexBuffer: IndexBuffer;

	static inline var triangleBufferSize: Int = 1000;
	static var triangleBufferIndex: Int;
	static var triangleVertexBuffer: VertexBuffer;
	static var triangleVertices: Float32Array;
	static var triangleIndexBuffer: IndexBuffer;

	var g: Graphics;
	var myPipeline: PipelineCache = null;
	public var pipeline(get, set): PipelineCache;

	public function new(g4: Graphics) {
		this.g = g4;
		bufferIndex = 0;
		triangleBufferIndex = 0;
		initShaders();
		myPipeline = standardColorPipeline;
		initBuffers();
	}

	private function get_pipeline(): PipelineCache {
		return myPipeline;
	}

	private function set_pipeline(pipe: PipelineCache): PipelineCache {
		myPipeline = pipe != null ? pipe : standardColorPipeline;
		return myPipeline;
	}

	public function setProjection(projectionMatrix: FastMatrix4): Void {
		this.projectionMatrix = projectionMatrix;
	}

	private static function initShaders(): Void {
		if (structure == null) {
			structure = Graphics2.createColoredVertexStructure();
		}
		if (standardColorPipeline == null) {
			var pipeline = Graphics2.createColoredPipeline(structure);
			pipeline.compile();
			standardColorPipeline = new PipelineCache(pipeline);
		}
	}

	function initBuffers(): Void {
		if (rectVertexBuffer == null) {
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

	public function setRectColors(opacity: FastFloat, color: Color): Void {
		var baseIndex: Int = bufferIndex * 7 * 4;

		var a: FastFloat = opacity * color.A;
		var r: FastFloat = a * color.R;
		var g: FastFloat = a * color.G;
		var b: FastFloat = a * color.B;

		rectVertices.set(baseIndex +  3, r);
		rectVertices.set(baseIndex +  4, g);
		rectVertices.set(baseIndex +  5, b);
		rectVertices.set(baseIndex +  6, a);

		rectVertices.set(baseIndex + 10, r);
		rectVertices.set(baseIndex + 11, g);
		rectVertices.set(baseIndex + 12, b);
		rectVertices.set(baseIndex + 13, a);

		rectVertices.set(baseIndex + 17, r);
		rectVertices.set(baseIndex + 18, g);
		rectVertices.set(baseIndex + 19, b);
		rectVertices.set(baseIndex + 20, a);

		rectVertices.set(baseIndex + 24, r);
		rectVertices.set(baseIndex + 25, g);
		rectVertices.set(baseIndex + 26, b);
		rectVertices.set(baseIndex + 27, a);
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

	private function setTriColors(opacity: FastFloat, color: Color): Void {
		var baseIndex: Int = triangleBufferIndex * 7 * 3;

		var a: FastFloat = opacity * color.A;
		var r: FastFloat = a * color.R;
		var g: FastFloat = a * color.G;
		var b: FastFloat = a * color.B;

		triangleVertices.set(baseIndex +  3, r);
		triangleVertices.set(baseIndex +  4, g);
		triangleVertices.set(baseIndex +  5, b);
		triangleVertices.set(baseIndex +  6, a);

		triangleVertices.set(baseIndex + 10, r);
		triangleVertices.set(baseIndex + 11, g);
		triangleVertices.set(baseIndex + 12, b);
		triangleVertices.set(baseIndex + 13, a);

		triangleVertices.set(baseIndex + 17, r);
		triangleVertices.set(baseIndex + 18, g);
		triangleVertices.set(baseIndex + 19, b);
		triangleVertices.set(baseIndex + 20, a);
	}

	private function drawBuffer(trisDone: Bool): Void {
		if (!trisDone) endTris(true);

		rectVertexBuffer.unlock(bufferIndex * 4);
		g.setVertexBuffer(rectVertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.setPipeline(myPipeline.pipeline);
		g.setMatrix(myPipeline.projectionLocation, projectionMatrix);

		g.drawIndexedVertices(0, bufferIndex * 2 * 3);

		bufferIndex = 0;
		rectVertices = rectVertexBuffer.lock();
	}

	private function drawTriBuffer(rectsDone: Bool): Void {
		if (!rectsDone) endRects(true);

		triangleVertexBuffer.unlock(triangleBufferIndex * 3);
		g.setVertexBuffer(triangleVertexBuffer);
		g.setIndexBuffer(triangleIndexBuffer);
		g.setPipeline(myPipeline.pipeline);
		g.setMatrix(myPipeline.projectionLocation, projectionMatrix);

		g.drawIndexedVertices(0, triangleBufferIndex * 3);

		triangleBufferIndex = 0;
		triangleVertices = triangleVertexBuffer.lock();
	}

	public function fillRect(opacity: FastFloat, color: Color,
		bottomleftx: Float, bottomlefty: Float,
		topleftx: Float, toplefty: Float,
		toprightx: Float, toprighty: Float,
		bottomrightx: Float, bottomrighty: Float): Void {
		if (triangleBufferIndex > 0) drawTriBuffer(true); // Flush other buffer for right render order

		if (bufferIndex + 1 >= bufferSize) drawBuffer(false);

		setRectColors(opacity, color);
		setRectVertices(bottomleftx, bottomlefty, topleftx, toplefty, toprightx, toprighty, bottomrightx, bottomrighty);
		++bufferIndex;
	}

	public function fillTriangle(opacity: FastFloat, color: Color, x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		if (bufferIndex > 0) drawBuffer(true); // Flush other buffer for right render order

		if (triangleBufferIndex + 1 >= triangleBufferSize) drawTriBuffer(false);

		setTriColors(opacity, color);
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

class TextShaderPainter {
	var projectionMatrix: FastMatrix4;
	static var standardTextPipeline: PipelineCache = null;
	static var structure: VertexStructure = null;
	static inline var bufferSize: Int = 1000;
	static var bufferIndex: Int;
	static var rectVertexBuffer: VertexBuffer;
	static var rectVertices: Float32Array;
	static var indexBuffer: IndexBuffer;
	var font: Kravur;
	static var lastTexture: Image;
	var g: Graphics;
	var myPipeline: PipelineCache = null;
	public var pipeline(get, set): PipelineCache;
	public var fontSize: Int;
	var bilinear: Bool = false;

	public function new(g4: Graphics) {
		this.g = g4;
		bufferIndex = 0;
		initShaders();
		myPipeline = standardTextPipeline;
		initBuffers();
	}

	private function get_pipeline(): PipelineCache {
		return myPipeline;
	}

	private function set_pipeline(pipe: PipelineCache): PipelineCache {
		myPipeline = pipe != null ? pipe : standardTextPipeline;
		return myPipeline;
	}

	public function setProjection(projectionMatrix: FastMatrix4): Void {
		this.projectionMatrix = projectionMatrix;
	}

	private static function initShaders(): Void {
		if (structure == null) {
			structure = Graphics2.createTextVertexStructure();
		}
		if (standardTextPipeline == null) {
			var pipeline = Graphics2.createTextPipeline(structure);
			pipeline.compile();
			standardTextPipeline = new PipelineCache(pipeline);
		}
	}

	function initBuffers(): Void {
		if (rectVertexBuffer == null) {
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

	private function setRectColors(opacity: FastFloat, color: Color): Void {
		var baseIndex: Int = bufferIndex * 9 * 4;
		var a: FastFloat = opacity * color.A;
		rectVertices.set(baseIndex +  5, color.R);
		rectVertices.set(baseIndex +  6, color.G);
		rectVertices.set(baseIndex +  7, color.B);
		rectVertices.set(baseIndex +  8, a);

		rectVertices.set(baseIndex + 14, color.R);
		rectVertices.set(baseIndex + 15, color.G);
		rectVertices.set(baseIndex + 16, color.B);
		rectVertices.set(baseIndex + 17, a);

		rectVertices.set(baseIndex + 23, color.R);
		rectVertices.set(baseIndex + 24, color.G);
		rectVertices.set(baseIndex + 25, color.B);
		rectVertices.set(baseIndex + 26, a);

		rectVertices.set(baseIndex + 32, color.R);
		rectVertices.set(baseIndex + 33, color.G);
		rectVertices.set(baseIndex + 34, color.B);
		rectVertices.set(baseIndex + 35, a);
	}

	private function drawBuffer(): Void {
		rectVertexBuffer.unlock(bufferIndex * 4);
		g.setVertexBuffer(rectVertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.setPipeline(myPipeline.pipeline);
		g.setTexture(myPipeline.textureLocation, lastTexture);
		g.setMatrix(myPipeline.projectionLocation, projectionMatrix);
		g.setTextureParameters(myPipeline.textureLocation, TextureAddressing.Clamp, TextureAddressing.Clamp, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, MipMapFilter.NoMipFilter);

		g.drawIndexedVertices(0, bufferIndex * 2 * 3);

		g.setTexture(myPipeline.textureLocation, null);
		bufferIndex = 0;
		rectVertices = rectVertexBuffer.lock();
	}

	public function setBilinearFilter(bilinear: Bool): Void {
		end();
		this.bilinear = bilinear;
	}

	public function setFont(font: Font): Void {
		this.font = cast(font, Kravur);
	}

	private static function findIndex(charCode: Int): Int {
		var glyphs = kha.graphics2.Graphics.fontGlyphs;
		var blocks = Kravur.KravurImage.charBlocks;
		var offset = 0;
		for (i in 0...Std.int(blocks.length / 2)) {
			var start = blocks[i * 2];
			var end = blocks[i * 2 + 1];
			if (charCode >= start && charCode <= end) return offset + charCode - start;
			offset += end - start + 1;
		}
		return 0;
	}

	var bakedQuadCache = new kha.Kravur.AlignedQuad();

	public function drawString(text: String, opacity: FastFloat, color: Color, x: Float, y: Float, transformation: FastMatrix3): Void {
		var font = this.font._get(fontSize);
		var tex = font.getTexture();
		if (lastTexture != null && tex != lastTexture) drawBuffer();
		lastTexture = tex;

		var xpos = x;
		var ypos = y;
		for (i in 0...text.length) {
			var charCode = StringTools.fastCodeAt(text, i);
			var q = font.getBakedQuad(bakedQuadCache, findIndex(charCode), xpos, ypos);
			if (q != null) {
				if (bufferIndex + 1 >= bufferSize) drawBuffer();
				setRectColors(opacity, color);
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
	}

	public function drawCharacters(text: Array<Int>, start: Int, length: Int, opacity: FastFloat, color: Color, x: Float, y: Float, transformation: FastMatrix3): Void {
		var font = this.font._get(fontSize);
		var tex = font.getTexture();
		if (lastTexture != null && tex != lastTexture) drawBuffer();
		lastTexture = tex;

		var xpos = x;
		var ypos = y;
		for (i in start...start + length) {
			var q = font.getBakedQuad(bakedQuadCache, findIndex(text[i]), xpos, ypos);
			if (q != null) {
				if (bufferIndex + 1 >= bufferSize) drawBuffer();
				setRectColors(opacity, color);
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
	}

	public function end(): Void {
		if (bufferIndex > 0) drawBuffer();
		lastTexture = null;
	}
}

class Graphics2 extends kha.graphics2.Graphics {
	private var myColor: Color;
	private var myFont: Font;
	private var projectionMatrix: FastMatrix4;
	public var imagePainter: ImageShaderPainter;
	private var coloredPainter: ColoredShaderPainter;
	private var textPainter: TextShaderPainter;
	private static var videoPipeline: PipelineState;
	private var canvas: Canvas;
	private var g: Graphics;
	static var current: Graphics2 = null;

	public function new(canvas: Canvas) {
		super();
		color = Color.White;
		this.canvas = canvas;
		g = canvas.g4;
		imagePainter = new ImageShaderPainter(g);
		coloredPainter = new ColoredShaderPainter(g);
		textPainter = new TextShaderPainter(g);
		textPainter.fontSize = fontSize;
		projectionMatrix = FastMatrix4.identity();
		setProjection();

		if (videoPipeline == null) {
			videoPipeline = createImagePipeline(createImageVertexStructure());
			videoPipeline.fragmentShader = Shaders.painter_video_frag;
			videoPipeline.vertexShader = Shaders.painter_video_vert;
			videoPipeline.compile();
		}
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
			projectionMatrix.setFrom(FastMatrix4.orthogonalProjection(0, width, height, 0, 0.1, 1000));
		}
		else {
			if (!Image.nonPow2Supported) {
				width = upperPowerOfTwo(width);
				height = upperPowerOfTwo(height);
			}
			if (Image.renderTargetsInvertedY()) {
				projectionMatrix.setFrom(FastMatrix4.orthogonalProjection(0, width, 0, height, 0.1, 1000));
			}
			else {
				projectionMatrix.setFrom(FastMatrix4.orthogonalProjection(0, width, height, 0, 0.1, 1000));
			}
		}
		imagePainter.setProjection(projectionMatrix);
		coloredPainter.setProjection(projectionMatrix);
		textPainter.setProjection(projectionMatrix);
	}

	#if cpp
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
	#else
	public override function drawImage(img: kha.Image, x: FastFloat, y: FastFloat): Void {
		coloredPainter.end();
		textPainter.end();
		var xw: FastFloat = x + img.width;
		var yh: FastFloat = y + img.height;
		var p1 = transformation.multvec(new FastVector2(x, yh));
		var p2 = transformation.multvec(new FastVector2(x, y));
		var p3 = transformation.multvec(new FastVector2(xw, y));
		var p4 = transformation.multvec(new FastVector2(xw, yh));
		imagePainter.drawImage(img, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y, opacity, this.color);
	}
	#end

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
		coloredPainter.fillRect(opacity, color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y); // top

		p1.setFrom(transformation.multvec(new FastVector2(x - strength / 2, y + height - strength / 2)));
		p2.setFrom(transformation.multvec(new FastVector2(x - strength / 2, y + strength / 2)));
		p3.setFrom(transformation.multvec(new FastVector2(x + strength / 2, y + strength / 2)));
		p4.setFrom(transformation.multvec(new FastVector2(x + strength / 2, y + height - strength / 2)));
		coloredPainter.fillRect(opacity, color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y); // left

		p1.setFrom(transformation.multvec(new FastVector2(x - strength / 2, y + height + strength / 2)));
		p2.setFrom(transformation.multvec(new FastVector2(x - strength / 2, y + height - strength / 2)));
		p3.setFrom(transformation.multvec(new FastVector2(x + width + strength / 2, y + height - strength / 2)));
		p4.setFrom(transformation.multvec(new FastVector2(x + width + strength / 2, y + height + strength / 2)));
		coloredPainter.fillRect(opacity, color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y); // bottom

		p1.setFrom(transformation.multvec(new FastVector2(x + width - strength / 2, y + height - strength / 2)));
		p2.setFrom(transformation.multvec(new FastVector2(x + width - strength / 2, y + strength / 2)));
		p3.setFrom(transformation.multvec(new FastVector2(x + width + strength / 2, y + strength / 2)));
		p4.setFrom(transformation.multvec(new FastVector2(x + width + strength / 2, y + height - strength / 2)));
		coloredPainter.fillRect(opacity, color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y); // right
	}

	public override function fillRect(x: Float, y: Float, width: Float, height: Float): Void {
		imagePainter.end();
		textPainter.end();

		var p1 = transformation.multvec(new FastVector2(x, y + height));
		var p2 = transformation.multvec(new FastVector2(x, y));
		var p3 = transformation.multvec(new FastVector2(x + width, y));
		var p4 = transformation.multvec(new FastVector2(x + width, y + height));
		coloredPainter.fillRect(opacity, color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
	}

	public override function drawString(text: String, x: Float, y: Float): Void {
		imagePainter.end();
		coloredPainter.end();

		textPainter.drawString(text, opacity, color, x, y, transformation);
	}

	public override function drawCharacters(text: Array<Int>, start: Int, length: Int, x: Float, y: Float): Void {
		imagePainter.end();
		coloredPainter.end();

		textPainter.drawCharacters(text, start, length, opacity, color, x, y, transformation);
	}

	override public function get_font(): Font {
		return myFont;
	}

	override public function set_font(font: Font): Font {
		textPainter.setFont(font);
		return myFont = font;
	}

	override public function set_fontSize(value: Int): Int {
		return super.fontSize = textPainter.fontSize = value;
	}

	public override function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0): Void {
		imagePainter.end();
		textPainter.end();

		var vec = new FastVector2();
		if (y2 == y1) vec.setFrom(new FastVector2(0, -1));
		else vec.setFrom(new FastVector2(1, -(x2 - x1) / (y2 - y1)));
		vec.length = strength;
		var p1 = new FastVector2(x1 + 0.5 * vec.x, y1 + 0.5 * vec.y);
		var p2 = new FastVector2(x2 + 0.5 * vec.x, y2 + 0.5 * vec.y);
		var p3 = p1.sub(vec);
		var p4 = p2.sub(vec);

		p1.setFrom(transformation.multvec(p1));
		p2.setFrom(transformation.multvec(p2));
		p3.setFrom(transformation.multvec(p3));
		p4.setFrom(transformation.multvec(p4));

		coloredPainter.fillTriangle(opacity, color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
		coloredPainter.fillTriangle(opacity, color, p3.x, p3.y, p2.x, p2.y, p4.x, p4.y);
	}

	public override function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		imagePainter.end();
		textPainter.end();

		var p1 = transformation.multvec(new FastVector2(x1, y1));
		var p2 = transformation.multvec(new FastVector2(x2, y2));
		var p3 = transformation.multvec(new FastVector2(x3, y3));
		coloredPainter.fillTriangle(opacity, color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
	}

	private var myImageScaleQuality: ImageScaleQuality = ImageScaleQuality.Low;

	override private function get_imageScaleQuality(): ImageScaleQuality {
		return myImageScaleQuality;
	}

	override private function set_imageScaleQuality(value: ImageScaleQuality): ImageScaleQuality {
		if (value == myImageScaleQuality) {
			return value;
		}
		imagePainter.setBilinearFilter(value == ImageScaleQuality.High);
		textPainter.setBilinearFilter(value == ImageScaleQuality.High);
		return myImageScaleQuality = value;
	}

	private var myMipmapScaleQuality: ImageScaleQuality = ImageScaleQuality.Low;

	override private function get_mipmapScaleQuality(): ImageScaleQuality {
		return myMipmapScaleQuality;
	}

	override private function set_mipmapScaleQuality(value: ImageScaleQuality): ImageScaleQuality {
		imagePainter.setBilinearMipmapFilter(value == ImageScaleQuality.High);
		//textPainter.setBilinearMipmapFilter(value == ImageScaleQuality.High); // TODO (DK) implement for fonts as well?
		return myMipmapScaleQuality = value;
	}

	var pipelineCache = new Map<PipelineState, PipelineCache>();
	var lastPipeline: PipelineState = null;

	override private function setPipeline(pipeline: PipelineState): Void {
		if (pipeline == lastPipeline) {
			return;
		}
		lastPipeline = pipeline;
		flush();
		if (pipeline == null) {
			imagePainter.pipeline = null;
			coloredPainter.pipeline = null;
			textPainter.pipeline = null;
		}
		else {
			var cache = pipelineCache[pipeline];
			if (cache == null) {
				cache = new PipelineCache(pipeline);
				pipelineCache[pipeline] = cache;
			}
			imagePainter.pipeline = cache;
			coloredPainter.pipeline = cache;
			textPainter.pipeline = cache;
		}
	}

	var scissorEnabled = false;
	var scissorX: Int = -1;
	var scissorY: Int = -1;
	var scissorW: Int = -1;
	var scissorH: Int = -1;

	override public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		//if (!scissorEnabled || x != scissorX || y != scissorY || width != scissorW || height != scissorH) {
			scissorEnabled = true;
			scissorX = x;
			scissorY = y;
			scissorW = width;
			scissorH = height;
			flush();
			g.scissor(x, y, width, height);
		//}
	}

	override public function disableScissor(): Void {
		//if (scissorEnabled) {
			scissorEnabled = false;
			flush();
			g.disableScissor();
		//}
	}

	override public function begin(clear: Bool = true, clearColor: Color = null): Void {
		if (current == null) {
			current = this;
		}
		else {
			throw "End before you begin";
		}

		g.begin();
		if (clear) this.clear(clearColor);
		setProjection();
	}

	override public function clear(color: Color = null): Void {
		flush();
		g.clear(color == null ? Color.Black : color);
	}

	public override function flush(): Void {
		imagePainter.end();
		textPainter.end();
		coloredPainter.end();
	}

	public override function end(): Void {
		flush();
		g.end();

		if (current == this) {
			current = null;
		}
		else {
			throw "Begin before you end";
		}
	}

	private function drawVideoInternal(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {

	}

	override public function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {
		setPipeline(videoPipeline);
		drawVideoInternal(video, x, y, width, height);
		setPipeline(null);
	}

	public static function createImageVertexStructure(): VertexStructure {
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		return structure;
	}

	public static function createImagePipeline(structure: VertexStructure): PipelineState {
		var shaderPipeline = new PipelineState();
		shaderPipeline.fragmentShader = Shaders.painter_image_frag;
		shaderPipeline.vertexShader = Shaders.painter_image_vert;
		shaderPipeline.inputLayout = [structure];
		shaderPipeline.blendSource = BlendingFactor.BlendOne;
		shaderPipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		shaderPipeline.alphaBlendSource = BlendingFactor.BlendOne;
		shaderPipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		return shaderPipeline;
	}

	public static function createColoredVertexStructure(): VertexStructure {
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("vertexColor", VertexData.Float4);
		return structure;
	}

	public static function createColoredPipeline(structure: VertexStructure): PipelineState {
		var shaderPipeline = new PipelineState();
		shaderPipeline.fragmentShader = Shaders.painter_colored_frag;
		shaderPipeline.vertexShader = Shaders.painter_colored_vert;
		shaderPipeline.inputLayout = [structure];
		shaderPipeline.blendSource = BlendingFactor.BlendOne;
		shaderPipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		shaderPipeline.alphaBlendSource = BlendingFactor.BlendOne;
		shaderPipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		return shaderPipeline;
	}

	public static function createTextVertexStructure(): VertexStructure {
		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		return structure;
	}

	public static function createTextPipeline(structure: VertexStructure): PipelineState {
		var shaderPipeline = new PipelineState();
		shaderPipeline.fragmentShader = Shaders.painter_text_frag;
		shaderPipeline.vertexShader = Shaders.painter_text_vert;
		shaderPipeline.inputLayout = [structure];
		shaderPipeline.blendSource = BlendingFactor.SourceAlpha;
		shaderPipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		shaderPipeline.alphaBlendSource = BlendingFactor.SourceAlpha;
		shaderPipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		return shaderPipeline;
	}
}
