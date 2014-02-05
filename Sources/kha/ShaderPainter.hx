package kha;

import kha.graphics.ConstantLocation;
import kha.graphics.IndexBuffer;
import kha.graphics.Program;
import kha.graphics.Texture;
import kha.graphics.TextureFormat;
import kha.graphics.TextureUnit;
import kha.graphics.Usage;
import kha.graphics.VertexBuffer;
import kha.graphics.VertexData;
import kha.graphics.VertexStructure;
import kha.math.Vector2;

class ImageShaderPainter {
	private var projectionMatrix: Array<Float>;
	private var shaderProgram: Program;
	private var structure: VertexStructure;
	private var projectionLocation: ConstantLocation;
	private var textureLocation: TextureUnit;
	private static var bufferSize: Int = 100;
	private static var vertexSize: Int = 9;
	private var bufferIndex: Int;
	private var rectVertexBuffer: VertexBuffer;
    private var rectVertices: Array<Float>;
	private var indexBuffer: IndexBuffer;
	private var lastTexture: Texture;

	public function new(projectionMatrix: Array<Float>) {
		this.projectionMatrix = projectionMatrix;
		bufferIndex = 0;
		initShaders();
		initBuffers();
		projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
		textureLocation = shaderProgram.getTextureUnit("tex");
	}
	
	public function setProjection(projectionMatrix: Array<Float>): Void {
		this.projectionMatrix = projectionMatrix;
	}
	
	private function initShaders(): Void {
		var fragmentShader = Sys.graphics.createFragmentShader(Loader.the.getShader("painter-image.frag"));
		var vertexShader = Sys.graphics.createVertexShader(Loader.the.getShader("painter-image.vert"));
	
		shaderProgram = Sys.graphics.createProgram();
		shaderProgram.setFragmentShader(fragmentShader);
		shaderProgram.setVertexShader(vertexShader);

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		
		shaderProgram.link(structure);
	}
	
	function initBuffers(): Void {
		rectVertexBuffer = Sys.graphics.createVertexBuffer(bufferSize * 4, structure, Usage.DynamicUsage);
		rectVertices = rectVertexBuffer.lock();
		
		indexBuffer = Sys.graphics.createIndexBuffer(bufferSize * 3 * 2, Usage.StaticUsage);
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
	
	private function setRectVertices(left: Float, top: Float, right: Float, bottom: Float): Void {
		var baseIndex: Int = bufferIndex * vertexSize * 4;
		rectVertices[baseIndex +  0] = left;
		rectVertices[baseIndex +  1] = bottom;
		rectVertices[baseIndex +  2] = -5.0;
		
		rectVertices[baseIndex +  9] = left;
		rectVertices[baseIndex + 10] = top;
		rectVertices[baseIndex + 11] = -5.0;
		
		rectVertices[baseIndex + 18] = right;
		rectVertices[baseIndex + 19] = top;
		rectVertices[baseIndex + 20] = -5.0;
		
		rectVertices[baseIndex + 27] = right;
		rectVertices[baseIndex + 28] = bottom;
		rectVertices[baseIndex + 29] = -5.0;
	}
	
	private function setRectTexCoords(left: Float, top: Float, right: Float, bottom: Float): Void {
		var baseIndex: Int = bufferIndex * vertexSize * 4;
		rectVertices[baseIndex +  3] = left;
		rectVertices[baseIndex +  4] = bottom;
		
		rectVertices[baseIndex + 12] = left;
		rectVertices[baseIndex + 13] = top;
		
		rectVertices[baseIndex + 21] = right;
		rectVertices[baseIndex + 22] = top;
		
		rectVertices[baseIndex + 30] = right;
		rectVertices[baseIndex + 31] = bottom;
	}
	
	private function setRectColor(r: Float, g: Float, b: Float, a: Float): Void {
		var baseIndex: Int = bufferIndex * vertexSize * 4;
		rectVertices[baseIndex +  5] = r;
		rectVertices[baseIndex +  6] = g;
		rectVertices[baseIndex +  7] = b;
		rectVertices[baseIndex +  8] = a;
		
		rectVertices[baseIndex + 14] = r;
		rectVertices[baseIndex + 15] = g;
		rectVertices[baseIndex + 16] = b;
		rectVertices[baseIndex + 17] = a;
		
		rectVertices[baseIndex + 23] = r;
		rectVertices[baseIndex + 24] = g;
		rectVertices[baseIndex + 25] = b;
		rectVertices[baseIndex + 26] = a;
		
		rectVertices[baseIndex + 32] = r;
		rectVertices[baseIndex + 33] = g;
		rectVertices[baseIndex + 34] = b;
		rectVertices[baseIndex + 35] = a;
	}

	private function drawBuffer(): Void {
		Sys.graphics.setTexture(textureLocation, lastTexture);
		
		rectVertexBuffer.unlock();
		Sys.graphics.setVertexBuffer(rectVertexBuffer);
		Sys.graphics.setIndexBuffer(indexBuffer);
		Sys.graphics.setProgram(shaderProgram);
		Sys.graphics.setMatrix(projectionLocation, projectionMatrix);
		
		Sys.graphics.drawIndexedVertices(0, bufferIndex * 2 * 3);

		Sys.graphics.setTexture(textureLocation, null);
		bufferIndex = 0;
	}
	
	public function drawImage(img: kha.Image, x: Float, y: Float, opacity: Float): Void {
		var tex = cast(img, Texture);
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();
		
		var left: Float = x;
		var top: Float = y;
		var right: Float = x + img.width;
		var bottom: Float = y + img.height;
		
		setRectColor(1, 1, 1, opacity);
		setRectTexCoords(0, 0, tex.width / tex.realWidth, tex.height / tex.realHeight);
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = tex;
	}
	
	public function drawImage2(img: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float, rotation: Rotation, opacity: Float): Void {
		var tex = cast(img, Texture);
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();
		
		var left: Float = dx;
		var top: Float = dy;
		var right: Float = dx + dw;
		var bottom: Float = dy + dh;
		
		setRectTexCoords(sx / tex.realWidth, sy / tex.realHeight, (sx + sw) / tex.realWidth, (sy + sh) / tex.realHeight);
		setRectColor(1, 1, 1, opacity);
		
		if (rotation != null) {
			var lefttop = rotate(left, top, left + rotation.center.x, top + rotation.center.y, rotation.angle);
			var rightbottom = rotate(right, bottom, left + rotation.center.x, top + rotation.center.y, rotation.angle);
			var righttop = rotate(right, top, left + rotation.center.x, top + rotation.center.y, rotation.angle);
			var leftbottom = rotate(left, bottom, left + rotation.center.x, top + rotation.center.y, rotation.angle);
			
			var baseIndex: Int = bufferIndex * vertexSize * 4;
			rectVertices[baseIndex +  0] = leftbottom.x;
			rectVertices[baseIndex +  1] = leftbottom.y;
			rectVertices[baseIndex +  2] = -5.0;
			
			rectVertices[baseIndex +  9] = lefttop.x;
			rectVertices[baseIndex + 10] = lefttop.y;
			rectVertices[baseIndex + 11] = -5.0;
			
			rectVertices[baseIndex + 18] = righttop.x;
			rectVertices[baseIndex + 19] = righttop.y;
			rectVertices[baseIndex + 20] = -5.0;
			
			rectVertices[baseIndex + 27] = rightbottom.x;
			rectVertices[baseIndex + 28] = rightbottom.y;
			rectVertices[baseIndex + 29] = -5.0;
		}
		else {
			setRectVertices(left, top, right, bottom);
		}
		++bufferIndex;
		lastTexture = tex;
	}

	private function rotate(x: Float, y: Float, centerx: Float, centery: Float, angle: Float): Vector2 {
		var s = Math.sin(angle);
		var c = Math.cos(angle);
		
		x -= centerx;
		y -= centery;
		
		var xnew = x * c - y * s;
		var ynew = x * s + y * c;
		
		return new Vector2(xnew + centerx, ynew + centery);
	}
	
	/*
	POINT rotate_point(float cx,float cy,float angle,POINT p)
{
  float s = sin(angle);
  float c = cos(angle);

  // translate point back to origin:
  p.x -= cx;
  p.y -= cy;

  // rotate point
  float xnew = p.x * c - p.y * s;
  float ynew = p.x * s + p.y * c;

  // translate point back:
  p.x = xnew + cx;
  p.y = ynew + cy;
}
	*/
	
	public function end(): Void {
		if (bufferIndex > 0) drawBuffer();
		lastTexture = null;
	}
}

class ColoredShaderPainter {
	private var projectionMatrix: Array<Float>;
	private var shaderProgram: Program;
	private var structure: VertexStructure;
	private var projectionLocation: ConstantLocation;
	
	private static var bufferSize: Int = 100;
	private var bufferIndex: Int;
	private var rectVertexBuffer: VertexBuffer;
    private var rectVertices: Array<Float>;
	private var indexBuffer: IndexBuffer;
	
	private static var triangleBufferSize: Int = 100;
	private var triangleBufferIndex: Int;
	private var triangleVertexBuffer: VertexBuffer;
    private var triangleVertices: Array<Float>;
	private var triangleIndexBuffer: IndexBuffer;
	
	public function new(projectionMatrix: Array<Float>) {
		this.projectionMatrix = projectionMatrix;
		bufferIndex = 0;
		triangleBufferIndex = 0;
		initShaders();
		initBuffers();
		projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
	}
	
	private function initShaders(): Void {
		var fragmentShader = Sys.graphics.createFragmentShader(Loader.the.getShader("painter-colored.frag"));
		var vertexShader = Sys.graphics.createVertexShader(Loader.the.getShader("painter-colored.vert"));
	
		shaderProgram = Sys.graphics.createProgram();
		shaderProgram.setFragmentShader(fragmentShader);
		shaderProgram.setVertexShader(vertexShader);

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("vertexColor", VertexData.Float4);
		
		shaderProgram.link(structure);
	}
	
	function initBuffers(): Void {
		rectVertexBuffer = Sys.graphics.createVertexBuffer(bufferSize * 4, structure, Usage.DynamicUsage);
		rectVertices = rectVertexBuffer.lock();
		
		indexBuffer = Sys.graphics.createIndexBuffer(bufferSize * 3 * 2, Usage.StaticUsage);
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
		
		triangleVertexBuffer = Sys.graphics.createVertexBuffer(triangleBufferSize * 3, structure, Usage.DynamicUsage);
		triangleVertices = triangleVertexBuffer.lock();
		
		triangleIndexBuffer = Sys.graphics.createIndexBuffer(triangleBufferSize * 3, Usage.StaticUsage);
		var triIndices = triangleIndexBuffer.lock();
		for (i in 0...bufferSize) {
			triIndices[i * 3 + 0] = i * 3 + 0;
			triIndices[i * 3 + 1] = i * 3 + 1;
			triIndices[i * 3 + 2] = i * 3 + 2;
		}
		triangleIndexBuffer.unlock();
	}
	
	public function setRectVertices(left: Float, top: Float, right: Float, bottom: Float): Void {
		var baseIndex: Int = bufferIndex * 7 * 4;
		rectVertices[baseIndex +  0] = left;
		rectVertices[baseIndex +  1] = bottom;
		rectVertices[baseIndex +  2] = -5.0;
		
		rectVertices[baseIndex +  7] = left;
		rectVertices[baseIndex +  8] = top;
		rectVertices[baseIndex +  9] = -5.0;
		
		rectVertices[baseIndex + 14] = right;
		rectVertices[baseIndex + 15] = top;
		rectVertices[baseIndex + 16] = -5.0;
		
		rectVertices[baseIndex + 21] = right;
		rectVertices[baseIndex + 22] = bottom;
		rectVertices[baseIndex + 23] = -5.0;
	}
	
	public function setRectColors(color: Color): Void {
		var baseIndex: Int = bufferIndex * 7 * 4;
		rectVertices[baseIndex +  3] = color.R;
		rectVertices[baseIndex +  4] = color.G;
		rectVertices[baseIndex +  5] = color.B;
		rectVertices[baseIndex +  6] = color.A;
		
		rectVertices[baseIndex + 10] = color.R;
		rectVertices[baseIndex + 11] = color.G;
		rectVertices[baseIndex + 12] = color.B;
		rectVertices[baseIndex + 13] = color.A;
		
		rectVertices[baseIndex + 17] = color.R;
		rectVertices[baseIndex + 18] = color.G;
		rectVertices[baseIndex + 19] = color.B;
		rectVertices[baseIndex + 20] = color.A;
		
		rectVertices[baseIndex + 24] = color.R;
		rectVertices[baseIndex + 25] = color.G;
		rectVertices[baseIndex + 26] = color.B;
		rectVertices[baseIndex + 27] = color.A;
	}
	
	private function setTriVertices(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float): Void {
		var baseIndex: Int = triangleBufferIndex * 7 * 3;
		triangleVertices[baseIndex +  0] = x1;
		triangleVertices[baseIndex +  1] = y1;
		triangleVertices[baseIndex +  2] = -5.0;
		
		triangleVertices[baseIndex +  7] = x2;
		triangleVertices[baseIndex +  8] = y2;
		triangleVertices[baseIndex +  9] = -5.0;
		
		triangleVertices[baseIndex + 14] = x3;
		triangleVertices[baseIndex + 15] = y3;
		triangleVertices[baseIndex + 16] = -5.0;
	}
	
	private function setTriColors(color: Color): Void {
		var baseIndex: Int = triangleBufferIndex * 7 * 3;
		triangleVertices[baseIndex +  3] = color.R;
		triangleVertices[baseIndex +  4] = color.G;
		triangleVertices[baseIndex +  5] = color.B;
		triangleVertices[baseIndex +  6] = color.A;
		
		triangleVertices[baseIndex + 10] = color.R;
		triangleVertices[baseIndex + 11] = color.G;
		triangleVertices[baseIndex + 12] = color.B;
		triangleVertices[baseIndex + 13] = color.A;
		
		triangleVertices[baseIndex + 17] = color.R;
		triangleVertices[baseIndex + 18] = color.G;
		triangleVertices[baseIndex + 19] = color.B;
		triangleVertices[baseIndex + 20] = color.A;
	}

	private function drawBuffer(trisDone: Bool): Void {
		if (!trisDone) endTris(true);
		
		rectVertexBuffer.unlock();
		Sys.graphics.setVertexBuffer(rectVertexBuffer);
		Sys.graphics.setIndexBuffer(indexBuffer);
		Sys.graphics.setProgram(shaderProgram);
		Sys.graphics.setMatrix(projectionLocation, projectionMatrix);
		
		Sys.graphics.drawIndexedVertices(0, bufferIndex * 2 * 3);

		bufferIndex = 0;
	}
	
	private function drawTriBuffer(rectsDone: Bool): Void {
		if (!rectsDone) endRects(true);
		
		triangleVertexBuffer.unlock();
		Sys.graphics.setVertexBuffer(triangleVertexBuffer);
		Sys.graphics.setIndexBuffer(triangleIndexBuffer);
		Sys.graphics.setProgram(shaderProgram);
		Sys.graphics.setMatrix(projectionLocation, projectionMatrix);
		
		Sys.graphics.drawIndexedVertices(0, triangleBufferIndex * 3);

		triangleBufferIndex = 0;
	}
	
	public function fillRect(color: Color, x: Float, y: Float, width: Float, height: Float): Void {
		if (bufferIndex + 1 >= bufferSize) drawBuffer(false);
		
		var left: Float = x;
		var top: Float = y;
		var right: Float = x + width;
		var bottom: Float = y + height;
		
		setRectColors(color);
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
	}
	
	public function fillTriangle(color: Color, x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		if (triangleBufferIndex + 1 >= triangleBufferSize) drawTriBuffer(false);
		
		setTriColors(color);
		setTriVertices(x1, y1, x2, y2, x3, y3);
		++triangleBufferIndex;
	}
	
	public function endTris(rectsDone: Bool): Void {
		if (triangleBufferIndex > 0) drawTriBuffer(rectsDone);
	}
	
	public function endRects(trisDone: Bool): Void {
		if (bufferIndex > 0) drawBuffer(trisDone);
	}
	
	public function end(): Void {
		endTris(false);
		endRects(false);
	}
}

@:headerClassCode("const wchar_t* wtext;")
class TextShaderPainter {
	private var projectionMatrix: Array<Float>;
	private var shaderProgram: Program;
	private var structure: VertexStructure;
	private var projectionLocation: ConstantLocation;
	private var textureLocation: TextureUnit;
	private static var bufferSize: Int = 100;
	private var bufferIndex: Int;
	private var rectVertexBuffer: VertexBuffer;
    private var rectVertices: Array<Float>;
	private var indexBuffer: IndexBuffer;
	private var font: Kravur;
	private var lastTexture: Texture;
	
	public function new(projectionMatrix: Array<Float>) {
		this.projectionMatrix = projectionMatrix;
		bufferIndex = 0;
		initShaders();
		initBuffers();
		projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
		textureLocation = shaderProgram.getTextureUnit("tex");
	}
	
	private function initShaders(): Void {
		var fragmentShader = Sys.graphics.createFragmentShader(Loader.the.getShader("painter-text.frag"));
		var vertexShader = Sys.graphics.createVertexShader(Loader.the.getShader("painter-text.vert"));
	
		shaderProgram = Sys.graphics.createProgram();
		shaderProgram.setFragmentShader(fragmentShader);
		shaderProgram.setVertexShader(vertexShader);

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		
		shaderProgram.link(structure);
	}
	
	function initBuffers(): Void {
		rectVertexBuffer = Sys.graphics.createVertexBuffer(bufferSize * 4, structure, Usage.DynamicUsage);
		rectVertices = rectVertexBuffer.lock();
		
		indexBuffer = Sys.graphics.createIndexBuffer(bufferSize * 3 * 2, Usage.StaticUsage);
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
	
	private function setRectVertices(left: Float, top: Float, right: Float, bottom: Float): Void {
		var baseIndex: Int = bufferIndex * 9 * 4;
		rectVertices[baseIndex +  0] = left;
		rectVertices[baseIndex +  1] = bottom;
		rectVertices[baseIndex +  2] = -5.0;
		
		rectVertices[baseIndex +  9] = left;
		rectVertices[baseIndex + 10] = top;
		rectVertices[baseIndex + 11] = -5.0;
		
		rectVertices[baseIndex + 18] = right;
		rectVertices[baseIndex + 19] = top;
		rectVertices[baseIndex + 20] = -5.0;
		
		rectVertices[baseIndex + 27] = right;
		rectVertices[baseIndex + 28] = bottom;
		rectVertices[baseIndex + 29] = -5.0;
	}
	
	private function setRectTexCoords(left: Float, top: Float, right: Float, bottom: Float): Void {
		var baseIndex: Int = bufferIndex * 9 * 4;
		rectVertices[baseIndex +  3] = left;
		rectVertices[baseIndex +  4] = bottom;
		
		rectVertices[baseIndex + 12] = left;
		rectVertices[baseIndex + 13] = top;
		
		rectVertices[baseIndex + 21] = right;
		rectVertices[baseIndex + 22] = top;
		
		rectVertices[baseIndex + 30] = right;
		rectVertices[baseIndex + 31] = bottom;
	}
	
	private function setRectColors(color: Color): Void {
		var baseIndex: Int = bufferIndex * 9 * 4;
		rectVertices[baseIndex +  5] = color.R;
		rectVertices[baseIndex +  6] = color.G;
		rectVertices[baseIndex +  7] = color.B;
		rectVertices[baseIndex +  8] = color.A;
		
		rectVertices[baseIndex + 14] = color.R;
		rectVertices[baseIndex + 15] = color.G;
		rectVertices[baseIndex + 16] = color.B;
		rectVertices[baseIndex + 17] = color.A;
		
		rectVertices[baseIndex + 23] = color.R;
		rectVertices[baseIndex + 24] = color.G;
		rectVertices[baseIndex + 25] = color.B;
		rectVertices[baseIndex + 26] = color.A;
		
		rectVertices[baseIndex + 32] = color.R;
		rectVertices[baseIndex + 33] = color.G;
		rectVertices[baseIndex + 34] = color.B;
		rectVertices[baseIndex + 35] = color.A;
	}
	
	private function drawBuffer(): Void {
		Sys.graphics.setTexture(textureLocation, lastTexture);
		
		rectVertexBuffer.unlock();
		Sys.graphics.setVertexBuffer(rectVertexBuffer);
		Sys.graphics.setIndexBuffer(indexBuffer);
		Sys.graphics.setProgram(shaderProgram);
		Sys.graphics.setMatrix(projectionLocation, projectionMatrix);
		
		Sys.graphics.drawIndexedVertices(0, bufferIndex * 2 * 3);

		Sys.graphics.setTexture(textureLocation, null);
		bufferIndex = 0;
	}
	
	public function setFont(font: Font): Void {
		this.font = cast(font, Kravur);
	}
	
	private var text: String;
	
	@:functionCode('
		wtext = text.__WCStr();
	')
	private function startString(text: String): Void {
		this.text = text;
	}
	
	@:functionCode('
		return wtext[position];
	')
	private function charCodeAt(position: Int): Int {
		return text.charCodeAt(position);
	}
	
	@:functionCode('
		return wcslen(wtext);
	')
	private function stringLength(): Int {
		return text.length;
	}
	
	@:functionCode('
		wtext = 0;
	')
	private function endString(): Void {
		text = null;
	}
	
	public function drawString(text: String, color: Color, x: Float, y: Float): Void {
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
				setRectVertices(q.x0, q.y0, q.x1, q.y1);
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

class ShaderPainter extends Painter {
	private var tx: Float = 0;
	private var ty: Float = 0;
	private var color: Color;
	private var projectionMatrix: Array<Float>;
	private var imagePainter: ImageShaderPainter;
	private var coloredPainter: ColoredShaderPainter;
	private var textPainter: TextShaderPainter;
	private var width: Float;
	private var height: Float;
	private var borderX: Float;
	private var borderY: Float;
	private var renderTexture: Texture;
	
	public function new(width: Int, height: Int) {
		super();
		color = Color.fromBytes(0, 0, 0);
		setScreenSize(width, height, 0, 0);
	}
	
	public function setScreenSize(width: Int, height: Int, borderX: Float, borderY: Float) {
		renderTexture = Sys.graphics.createRenderTargetTexture(width, height, TextureFormat.RGBA32, false);
		this.width = renderTexture.realWidth;
		this.height = renderTexture.realHeight;
		this.borderX = borderX;
		this.borderY = borderY;
		//projectionMatrix = ortho( 0, width, height, 0, 0.1, 1000);
		projectionMatrix = ortho(-borderX, renderTexture.realWidth + borderX, renderTexture.realHeight + borderY, -borderY, 0.1, 1000);
		imagePainter = new ImageShaderPainter(projectionMatrix);
		coloredPainter = new ColoredShaderPainter(projectionMatrix);
		textPainter = new TextShaderPainter(projectionMatrix);
	}
	
	private function ortho(left: Float, right: Float, bottom: Float, top: Float, zn: Float, zf: Float): Array<Float> {
		var tx: Float = -(right + left) / (right - left);
		var ty: Float = -(top + bottom) / (top - bottom);
		var tz: Float = -(zf + zn) / (zf - zn);
		//var tz : Float = -zn / (zf - zn);
		return [
			2 / (right - left), 0,                  0,              0,
			0,                  2 / (top - bottom), 0,              0,
			0,                  0,                  -2 / (zf - zn), 0,
			tx,                 ty,                 tz,             1
		];
	}
	
	public override function drawImage(img: kha.Image, x: Float, y: Float): Void {
		coloredPainter.end();
		textPainter.end();
		
		imagePainter.drawImage(img, tx + x, ty + y, opacity);
	}
	
	public override function drawImage2(img: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float, rotation: Rotation = null): Void {
		coloredPainter.end();
		textPainter.end();
		
		imagePainter.drawImage2(img, sx, sy, sw, sh, tx + dx, ty + dy, dw, dh, rotation, opacity);
	}
	
	public override function setColor(color: Color): Void {
		this.color = Color.fromValue(color.value);
	}
	
	public override function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0 ): Void {
		imagePainter.end();
		textPainter.end();
		
		coloredPainter.fillRect(color, tx + x, ty + y, width, strength);
		coloredPainter.fillRect(color, tx + x, ty + y, strength, height);
		coloredPainter.fillRect(color, tx + x, ty + y + height, width, -strength);
		coloredPainter.fillRect(color, tx + x + width, ty + y, -strength, height);
	}
	
	public override function fillRect(x: Float, y: Float, width: Float, height: Float): Void {
		imagePainter.end();
		textPainter.end();
		
		coloredPainter.fillRect(color, tx + x, ty + y, width, height);
	}

	public override function translate(x: Float, y: Float) {
		tx = x;
		ty = y;
	}

	public override function drawString(text: String, x: Float, y: Float): Void {
		imagePainter.end();
		coloredPainter.end();
		
		textPainter.drawString(text, color, tx + x, ty + y);
	}

	public override function setFont(font: Font): Void {
		textPainter.setFont(font);
	}

	public override function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0): Void {
		imagePainter.end();
		textPainter.end();
		
		x1 += tx;
		y1 += ty;
		x2 += tx;
		y2 += ty;
		
		var vec: Vector2;
		if (y2 == y1) vec = new Vector2(0, -1);
		else vec = new Vector2(1, -(x2 - x1) / (y2 - y1));
		vec.length = strength;
		var p1 = new Vector2(x1 + 0.5 * vec.x, y1 + 0.5 * vec.y);
		var p2 = new Vector2(x2 + 0.5 * vec.x, y2 + 0.5 * vec.y);
		var p3 = p1.sub(vec);
		var p4 = p2.sub(vec);
		
		coloredPainter.fillTriangle(color, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
		coloredPainter.fillTriangle(color, p3.x, p3.y, p2.x, p2.y, p4.x, p4.y);		
	}

	public override function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		imagePainter.end();
		textPainter.end();
		
		coloredPainter.fillTriangle(color, tx + x1, ty + y1, tx + x2, ty + y2, tx + x3, ty + y3);
	}
	
	public override function begin(): Void {
		Sys.graphics.renderToTexture(renderTexture);
		Sys.graphics.clear(kha.Color.fromBytes(0, 0, 0));
		translate(0, 0);
	}
	
	public override function end(): Void {
		imagePainter.end();
		textPainter.end();
		coloredPainter.fillRect(Color.ColorBlack, -borderX, 0, borderX, height);
		coloredPainter.fillRect(Color.ColorBlack, width, 0, borderX, height);
		coloredPainter.fillRect(Color.ColorBlack, 0, -borderY, width, borderY);
		coloredPainter.fillRect(Color.ColorBlack, 0, height, width, borderY);
		coloredPainter.end();
		
		Sys.graphics.renderToBackbuffer();
		if (Sys.graphics.renderTargetsInvertedY()) {
			imagePainter.setProjection(ortho(0, Sys.pixelWidth, 0, Sys.pixelHeight, 0.1, 1000));
			imagePainter.drawImage2(renderTexture, 0, renderTexture.realHeight - renderTexture.height, renderTexture.width, renderTexture.height, 0, 0, Sys.pixelWidth, Sys.pixelHeight, null, 1);
		}
		else {
			imagePainter.setProjection(ortho(0, Sys.pixelWidth, Sys.pixelHeight, 0, 0.1, 1000));
			imagePainter.drawImage2(renderTexture, 0, 0, renderTexture.width, renderTexture.height, 0, 0, Sys.pixelWidth, Sys.pixelHeight, null, 1);
		}
		imagePainter.end();
		imagePainter.setProjection(ortho(-borderX, renderTexture.realWidth + borderX, renderTexture.realHeight + borderY, -borderY, 0.1, 1000));
	}
}
