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
import kha.graphics2.Primitive;
import kha.graphics2.Style;

class ImageShaderPainter {
	private var projectionMatrix: FastMatrix4;
	private static var shaderPipeline: PipelineState = null;
	private static var structure: VertexStructure = null;
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
	private var bilinearMipmaps: Bool = false;    
	private var g: Graphics;
	private var myPipeline: PipelineState = null;
	public var pipeline(get, set): PipelineState;
	
	public var sourceBlend: BlendingFactor = BlendingFactor.Undefined;
	public var destinationBlend: BlendingFactor = BlendingFactor.Undefined;
	
	public function new(g4: Graphics) {
		this.g = g4;
		bufferIndex = 0;
		initShaders();
		initBuffers();
		projectionLocation = shaderPipeline.getConstantLocation("projectionMatrix");
		textureLocation = shaderPipeline.getTextureUnit("tex");
	}
	
	private function get_pipeline(): PipelineState {
		return myPipeline;
	}
	
	private function set_pipeline(pipe: PipelineState): PipelineState {
		if (pipe == null) {
			projectionLocation = shaderPipeline.getConstantLocation("projectionMatrix");
			textureLocation = shaderPipeline.getTextureUnit("tex");
		}
		else {
			projectionLocation = pipe.getConstantLocation("projectionMatrix");
			textureLocation = pipe.getTextureUnit("tex");
		}
		return myPipeline = pipe;
	}
	
	public function setProjection(projectionMatrix: FastMatrix4): Void {
		this.projectionMatrix = projectionMatrix;
	}
	
	private static function initShaders(): Void {
		if (shaderPipeline != null) return;
		
		shaderPipeline = new PipelineState();
		shaderPipeline.fragmentShader = Shaders.painter_image_frag;
		shaderPipeline.vertexShader = Shaders.painter_image_vert;

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		shaderPipeline.inputLayout = [structure];
		
		shaderPipeline.blendSource = BlendingFactor.BlendOne;
		shaderPipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		shaderPipeline.alphaBlendSource = BlendingFactor.SourceAlpha;
		shaderPipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		
		shaderPipeline.compile();
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
		g.setPipeline(pipeline == null ? shaderPipeline : pipeline);
		g.setTexture(textureLocation, lastTexture);
		g.setTextureParameters(textureLocation, TextureAddressing.Clamp, TextureAddressing.Clamp, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinearMipmaps ? MipMapFilter.LinearMipFilter : MipMapFilter.NoMipFilter);
		g.setMatrix(projectionLocation, projectionMatrix);
		//if (sourceBlend == BlendingOperation.Undefined || destinationBlend == BlendingOperation.Undefined) {
		//	g.setBlendingMode(BlendingOperation.BlendOne, BlendingOperation.InverseSourceAlpha);
		//}
		//else {
		//	g.setBlendingMode(sourceBlend, destinationBlend);
		//}
		
		g.drawIndexedVertices(0, bufferIndex * 2 * 3);

		g.setTexture(textureLocation, null);
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
	private var projectionMatrix: FastMatrix4;
	private static var shaderPipeline: PipelineState = null;
	private static var structure: VertexStructure = null;
	private var projectionLocation: ConstantLocation;
	
	private static var maxVertexSize: Int = 1024;

	private var vertexBuffer: VertexBuffer;
	private var vertexIndex: Int;
    private var vertices: Float32Array;

	private var indexBuffer: IndexBuffer;
	private var indexIndex: Int;
	private var indices: Array<Int>;
	
	private var g: Graphics;
	private var myPipeline: PipelineState = null;
	public var pipeline(get, set): PipelineState;
	
	public var sourceBlend: BlendingFactor = BlendingFactor.Undefined;
	public var destinationBlend: BlendingFactor = BlendingFactor.Undefined;
	
	public function new(g4: Graphics) {
		this.g = g4;
		indexIndex = 0;
		vertexIndex = 0;
		initShaders();
		initBuffers();
		projectionLocation = shaderPipeline.getConstantLocation("projectionMatrix");
	}
	
	private function get_pipeline(): PipelineState {
		return myPipeline;
	}
	
	private function set_pipeline(pipe: PipelineState): PipelineState {
		if (pipe == null) {
			projectionLocation = shaderPipeline.getConstantLocation("projectionMatrix");
		}
		else {
			projectionLocation = pipe.getConstantLocation("projectionMatrix");
		}
		return myPipeline = pipe;
	}
	
	public function setProjection(projectionMatrix: FastMatrix4): Void {
		this.projectionMatrix = projectionMatrix;
	}
	
	private static function initShaders(): Void {
		if (shaderPipeline != null) return;
		
		shaderPipeline = new PipelineState();
		shaderPipeline.fragmentShader = Shaders.painter_colored_frag;
		shaderPipeline.vertexShader = Shaders.painter_colored_vert;

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("vertexColor", VertexData.Float4);
		shaderPipeline.inputLayout = [structure];
		
		shaderPipeline.blendSource = BlendingFactor.SourceAlpha;
		shaderPipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		shaderPipeline.alphaBlendSource = BlendingFactor.SourceAlpha;
		shaderPipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
			
		shaderPipeline.compile();
	}
	
	function initBuffers(): Void {
		vertexBuffer = new VertexBuffer(maxVertexSize, structure, Usage.DynamicUsage);
		vertices = vertexBuffer.lock();
		
		indexBuffer = new IndexBuffer(maxVertexSize, Usage.StaticUsage);
		indices = indexBuffer.lock();
	}

	public function addVertex(x: Float, y: Float, color: Color, transform: FastMatrix3): Void {
		var baseIndex = vertexIndex * structure.dataSize();

		var p = transform.multvec(new FastVector2(x, y));

		vertices.set(baseIndex + 0, p.x);
		vertices.set(baseIndex + 1, p.y);
		vertices.set(baseIndex + 2, -5.0);
		vertices.set(baseIndex + 3, color.R);
		vertices.set(baseIndex + 4, color.G);
		vertices.set(baseIndex + 5, color.B);
		vertices.set(baseIndex + 6, color.A);

		++vertexIndex;
	}

	public inline function addIndex(index: Int): Void {
		indices[indexIndex] = index;
		++indexIndex;
	}

	public function draw() {
		vertexBuffer.unlock();
		indexBuffer.unlock();

		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);

		g.setPipeline(pipeline == null ? shaderPipeline : pipeline);
		g.setMatrix(projectionLocation, projectionMatrix);
		
		g.drawIndexedVertices(0, indexIndex);

		indexIndex = 0;
		vertexIndex = 0;

		vertices = vertexBuffer.lock();
		indices = indexBuffer.lock();
	}

	public function addQuad(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, x4: Float, y4: Float, color: Color, transform: FastMatrix3): Void {
		if (vertexIndex + 4 >= maxVertexSize)
			draw();

		addIndex(vertexIndex + 0);
		addIndex(vertexIndex + 1);
		addIndex(vertexIndex + 2);
		addIndex(vertexIndex + 0);
		addIndex(vertexIndex + 2);
		addIndex(vertexIndex + 3);

		addVertex(x1, y1, color, transform);
		addVertex(x2, y2, color, transform);
		addVertex(x3, y3, color, transform);
		addVertex(x4, y4, color, transform);
	}

	public function addTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, color: Color, transform: FastMatrix3): Void {
		if (vertexIndex + 3 >= maxVertexSize)
			draw();
		
		addIndex(vertexIndex + 0);
		addIndex(vertexIndex + 1);
		addIndex(vertexIndex + 2);

		addVertex(x1, y1, color, transform);
		addVertex(x2, y2, color, transform);
		addVertex(x3, y3, color, transform);
	}

	public inline function end(): Void {
		draw();
	}

}

#if cpp
@:headerClassCode("const wchar_t* wtext;")
#end
class TextShaderPainter {
	private var projectionMatrix: FastMatrix4;
	private static var shaderPipeline: PipelineState = null;
	private static var structure: VertexStructure = null;
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
	private var myPipeline: PipelineState = null;
	public var pipeline(get, set): PipelineState;
	public var fontSize: Int;
	private var bilinear: Bool = false;
	
	public var sourceBlend: BlendingFactor = BlendingFactor.Undefined;
	public var destinationBlend: BlendingFactor = BlendingFactor.Undefined;
	
	public function new(g4: Graphics) {
		this.g = g4;
		bufferIndex = 0;
		initShaders();
		initBuffers();
		projectionLocation = shaderPipeline.getConstantLocation("projectionMatrix");
		textureLocation = shaderPipeline.getTextureUnit("tex");
	}
	
	private function get_pipeline(): PipelineState {
		return myPipeline;
	}
	
	private function set_pipeline(pipe: PipelineState): PipelineState {
		if (pipe == null) {
			projectionLocation = shaderPipeline.getConstantLocation("projectionMatrix");
			textureLocation = shaderPipeline.getTextureUnit("tex");
		}
		else {
			projectionLocation = pipe.getConstantLocation("projectionMatrix");
			textureLocation = pipe.getTextureUnit("tex");
		}
		return myPipeline = pipe;
	}
	
	public function setProjection(projectionMatrix: FastMatrix4): Void {
		this.projectionMatrix = projectionMatrix;
	}
	
	private static function initShaders(): Void {
		if (shaderPipeline != null) return;
		
		shaderPipeline = new PipelineState();
		shaderPipeline.fragmentShader = Shaders.painter_text_frag;
		shaderPipeline.vertexShader = Shaders.painter_text_vert;

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		shaderPipeline.inputLayout = [structure];
		
		shaderPipeline.blendSource = BlendingFactor.SourceAlpha;
		shaderPipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		shaderPipeline.alphaBlendSource = BlendingFactor.SourceAlpha;
		shaderPipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		
		shaderPipeline.compile();
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
		rectVertexBuffer.unlock();
		g.setVertexBuffer(rectVertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.setPipeline(pipeline == null ? shaderPipeline : pipeline);
		g.setTexture(textureLocation, lastTexture);
		g.setMatrix(projectionLocation, projectionMatrix);
		g.setTextureParameters(textureLocation, TextureAddressing.Clamp, TextureAddressing.Clamp, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, bilinear ? TextureFilter.LinearFilter : TextureFilter.PointFilter, MipMapFilter.NoMipFilter);
		//if (sourceBlend == BlendingOperation.Undefined || destinationBlend == BlendingOperation.Undefined) {
		//	g.setBlendingMode(BlendingOperation.SourceAlpha, BlendingOperation.InverseSourceAlpha);
		//}
		//else {
		//	g.setBlendingMode(sourceBlend, destinationBlend);
		//}
		
		g.drawIndexedVertices(0, bufferIndex * 2 * 3);

		g.setTexture(textureLocation, null);
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
	
	//TODO: Make this fast
	private static function findIndex(charcode: Int, fontGlyphs: Array<Int>): Int {
		for (i in 0...fontGlyphs.length) {
			if (fontGlyphs[i] == charcode) return i;
		}
		return 0;
	}
	
	public function drawString(text: String, opacity: FastFloat, color: Color, x: Float, y: Float, transformation: FastMatrix3, fontGlyphs: Array<Int>): Void {
		var font = this.font._get(fontSize, fontGlyphs);
		var tex = font.getTexture();
		if (lastTexture != null && tex != lastTexture) drawBuffer();
		lastTexture = tex;

		var xpos = x;
		var ypos = y;
		startString(text);
		for (i in 0...stringLength()) {
			var q = font.getBakedQuad(findIndex(charCodeAt(i), fontGlyphs), xpos, ypos);
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
	private var projectionMatrix: FastMatrix4;
	public var imagePainter: ImageShaderPainter;
	private var coloredPainter: ColoredShaderPainter;
	private var textPainter: TextShaderPainter;
	private static var videoPipeline: PipelineState;
	private var canvas: Canvas;
	private var g: Graphics;

	public function new(canvas: Canvas) {
		super();

		this.canvas = canvas;
		g = canvas.g4;
		imagePainter = new ImageShaderPainter(g);
		coloredPainter = new ColoredShaderPainter(g);
		textPainter = new TextShaderPainter(g);
		textPainter.fontSize = fontSize;
		setProjection();
		
		if (videoPipeline == null) {
			videoPipeline = new PipelineState();
			videoPipeline.fragmentShader = Shaders.painter_video_frag;
			videoPipeline.vertexShader = Shaders.painter_video_vert;

			var structure = new VertexStructure();
			structure.add("vertexPosition", VertexData.Float3);
			structure.add("texPosition", VertexData.Float2);
			structure.add("vertexColor", VertexData.Float4);
			videoPipeline.inputLayout = [structure];
			
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
			projectionMatrix = FastMatrix4.orthogonalProjection(0, width, height, 0, 0.1, 1000);
		} else {
			if (!Image.nonPow2Supported) {
				width = upperPowerOfTwo(width);
				height = upperPowerOfTwo(height);
			}
			if (g.renderTargetsInvertedY()) {
				projectionMatrix = FastMatrix4.orthogonalProjection(0, width, 0, height, 0.1, 1000);
			} else {
				projectionMatrix = FastMatrix4.orthogonalProjection(0, width, height, 0, 0.1, 1000);
			}
		}
		imagePainter.setProjection(projectionMatrix);
		coloredPainter.setProjection(projectionMatrix);
		textPainter.setProjection(projectionMatrix);
	}
	
	#if cpp
	public override function drawImage(img: kha.Image, x: FastFloat, y: FastFloat, ?style: Style): Void {
		coloredPainter.end();
		textPainter.end();

		if (style == null)
			style = this.style;

		var xw: FastFloat = x + img.width;
		var yh: FastFloat = y + img.height;
		
		var xx = Float32x4.loadFast(x, x, xw, xw);
		var yy = Float32x4.loadFast(yh, y, y, yh);
		
		var _00 = Float32x4.loadAllFast(transform._00);
		var _01 = Float32x4.loadAllFast(transform._01);
		var _02 = Float32x4.loadAllFast(transform._02);
		var _10 = Float32x4.loadAllFast(transform._10);
		var _11 = Float32x4.loadAllFast(transform._11);
		var _12 = Float32x4.loadAllFast(transform._12);
		var _20 = Float32x4.loadAllFast(transform._20);
		var _21 = Float32x4.loadAllFast(transform._21);
		var _22 = Float32x4.loadAllFast(transform._22);
		
		// matrix multiply
		var w = Float32x4.add(Float32x4.add(Float32x4.mul(_02, xx), Float32x4.mul(_12, yy)), _22);
		var px = Float32x4.div(Float32x4.add(Float32x4.add(Float32x4.mul(_00, xx), Float32x4.mul(_10, yy)), _20), w);
		var py = Float32x4.div(Float32x4.add(Float32x4.add(Float32x4.mul(_01, xx), Float32x4.mul(_11, yy)), _21), w);
		
		imagePainter.drawImage(img, Float32x4.get(px, 0), Float32x4.get(py, 0), Float32x4.get(px, 1), Float32x4.get(py, 1),
			Float32x4.get(px, 2), Float32x4.get(py, 2), Float32x4.get(px, 3), Float32x4.get(py, 3), style.fillColor.A, style.fillColor);
	}
	#else
	public override function drawImage(img: kha.Image, x: FastFloat, y: FastFloat, ?style: Style): Void {
		coloredPainter.end();
		textPainter.end();

		if (style == null)
			style = this.style;
		
		var xw: FastFloat = x + img.width;
		var yh: FastFloat = y + img.height;
		var p1 = transform.multvec(new FastVector2(x, yh));
		var p2 = transform.multvec(new FastVector2(x, y));
		var p3 = transform.multvec(new FastVector2(xw, y));
		var p4 = transform.multvec(new FastVector2(xw, yh));
		imagePainter.drawImage(img, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y, style.fillColor.A, style.fillColor);
	}
	#end
	
	public override function drawScaledSubImage(img: kha.Image, sx: FastFloat, sy: FastFloat, sw: FastFloat, sh: FastFloat, dx: FastFloat, dy: FastFloat, dw: FastFloat, dh: FastFloat, ?style: Style): Void {
		coloredPainter.end();
		textPainter.end();
		var p1 = transform.multvec(new FastVector2(dx, dy + dh));
		var p2 = transform.multvec(new FastVector2(dx, dy));
		var p3 = transform.multvec(new FastVector2(dx + dw, dy));
		var p4 = transform.multvec(new FastVector2(dx + dw, dy + dh));
		imagePainter.drawImage2(img, sx, sy, sw, sh, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y, style.fillColor.A, style.fillColor);
	}
	
	/*override public function get_color(): Color {
		return myColor;
	}
	
	override public function set_color(color: Color): Color {
		return myColor = color;
	}*/

	override function quad(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, x4: Float, y4: Float, ?style:Style): Void {
		imagePainter.end();
		textPainter.end();
		
		if (style == null)
			style = this.style;

		if (style.fill) {
			coloredPainter.addQuad(x1, y1, x2, y2, x3, y3, x4, y4, style.fillColor, transform);
		}
		if (style.stroke) {
			// TODO: Adjust line for corners
			line(x1, y1, x2, y2, style);
			line(x2, y2, x3, y3, style);
			line(x3, y3, x4, y4, style);
			line(x4, y4, x1, y1, style);
		}
	}

	override public function rect(x: Float, y: Float, width: Float, height: Float, ?style:Style): Void {
		imagePainter.end();
		textPainter.end();

		quad(x, y, x + width, y, x + width, y + height, x, y + height, style);
	}

	override public function line(x1: Float, y1: Float, x2: Float, y2: Float, ?style:Style): Void {
		imagePainter.end();
		textPainter.end();

		if (style == null)
			style = this.style;
		
		var vec: FastVector2;
		if (y2 == y1) vec = new FastVector2(0, -1);
		else vec = new FastVector2(1, -(x2 - x1) / (y2 - y1));
		vec.length = style.strokeWeight;
		var p1 = new FastVector2(x1 + 0.5 * vec.x, y1 + 0.5 * vec.y);
		var p2 = new FastVector2(x2 + 0.5 * vec.x, y2 + 0.5 * vec.y);
		var p3 = p2.sub(vec);
		var p4 = p1.sub(vec);
		
		coloredPainter.addQuad(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y, style.strokeColor, transform);
	}

	override public function triangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, ?style:Style): Void {
		imagePainter.end();
		textPainter.end();

		if (style == null)
			style = this.style;

		if (style.fill) {
			coloredPainter.addTriangle(x1, y1, x2, y2, x3, y3, style.fillColor, transform);
		}
		if (style.stroke) {
			// TODO: Adjust line for corners
			line(x1, y1, x2, y2, style);
			line(x2, y2, x3, y3, style);
			line(x3, y3, x1, y1, style);
		}
	}

	override public function beginShape(primitive:kha.graphics2.Primitive): Void {
	}

	override public function vertex(x:Float, y:Float, ?color:Color): Void {
		
	}

	override public function endShape(close:Bool): Void {

	}

	public override function drawString(text: String, x: Float, y: Float, ?style: Style): Void {
		imagePainter.end();
		coloredPainter.end();
		
		if (style == null)
			style = this.style;

		textPainter.drawString(text, style.fillColor.A, style.fillColor, x, y, getTransform(), fontGlyphs);
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
	
	private var myImageScaleQuality: ImageScaleQuality = ImageScaleQuality.High;
	
	override private function get_imageScaleQuality(): ImageScaleQuality {
		return myImageScaleQuality;
	}
	
	override private function set_imageScaleQuality(value: ImageScaleQuality): ImageScaleQuality {
		imagePainter.setBilinearFilter(value == ImageScaleQuality.High);
		textPainter.setBilinearFilter(value == ImageScaleQuality.High);
		return myImageScaleQuality = value;
	}
	
	private var myMipmapScaleQuality: ImageScaleQuality = ImageScaleQuality.High;

	override private function get_mipmapScaleQuality(): ImageScaleQuality {
		return myMipmapScaleQuality;
	}

	override private function set_mipmapScaleQuality(value: ImageScaleQuality): ImageScaleQuality {
		imagePainter.setBilinearMipmapFilter(value == ImageScaleQuality.High);
		//textPainter.setBilinearMipmapFilter(value == ImageScaleQuality.High); // TODO (DK) implement for fonts as well?
		return myMipmapScaleQuality = value;
	}
    
	override private function setPipeline(pipeline: PipelineState): Void {
		flush();
		imagePainter.pipeline = pipeline;
		coloredPainter.pipeline = pipeline;
		textPainter.pipeline = pipeline;
		if (pipeline != null) g.setPipeline(pipeline);
	}
	
	override public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		flush();
		g.scissor(x, y, width, height);
	}
	
	
	override public function disableScissor(): Void {
		flush();
		g.disableScissor();
	}
	
	override public function begin(clear: Bool = true, clearColor: Color = null): Void {
		g.begin();
		if (clear) this.clear(clearColor);
		setProjection();
	}
	
	override public function clear(color: Color = null): Void {
		g.clear(color == null ? Color.Black : color);
	}
	
	public override function flush(): Void {
		imagePainter.end();
		textPainter.end();
		coloredPainter.end();
	}
	
	public override function end(): Void {
		flush();
		resetTransform();
		g.end();
	}
	
	private function drawVideoInternal(video: kha.Video, x: Float, y: Float, width: Float, height: Float, ?style: Style): Void {
		
	}
	
	override public function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float, ?style: Style): Void {
		if (style == null)
			style = this.style;
		
		setPipeline(videoPipeline);
		drawVideoInternal(video, x, y, width, height, style);
		setPipeline(null);
	}
}
