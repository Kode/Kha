package kha;

import kha.graphics.ConstantLocation;
import kha.graphics.IndexBuffer;
import kha.graphics.Program;
import kha.graphics.Texture;
import kha.graphics.TextureUnit;
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
	
	private function initShaders(): Void {
		var fragmentShader = Sys.graphics.createFragmentShader(Loader.the.getShader("painter-image.frag"));
		var vertexShader = Sys.graphics.createVertexShader(Loader.the.getShader("painter-image.vert"));
	
		shaderProgram = Sys.graphics.createProgram();
		shaderProgram.setFragmentShader(fragmentShader);
		shaderProgram.setVertexShader(vertexShader);

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		
		shaderProgram.link(structure);
	}
	
	function initBuffers(): Void {
		rectVertexBuffer = Sys.graphics.createVertexBuffer(bufferSize * 4, structure);
		rectVertices = rectVertexBuffer.lock();
		
		indexBuffer = Sys.graphics.createIndexBuffer(bufferSize * 3 * 2);
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
		var baseIndex: Int = bufferIndex * 5 * 4;
		rectVertices[baseIndex +  0] = left;
		rectVertices[baseIndex +  1] = bottom;
		rectVertices[baseIndex +  2] = -5.0;
		
		rectVertices[baseIndex +  5] = left;
		rectVertices[baseIndex +  6] = top;
		rectVertices[baseIndex +  7] = -5.0;
		
		rectVertices[baseIndex + 10] = right;
		rectVertices[baseIndex + 11] = top;
		rectVertices[baseIndex + 12] = -5.0;
		
		rectVertices[baseIndex + 15] = right;
		rectVertices[baseIndex + 16] = bottom;
		rectVertices[baseIndex + 17] = -5.0;
	}
	
	private function setRectTexCoords(left: Float, top: Float, right: Float, bottom: Float): Void {
		var baseIndex: Int = bufferIndex * 5 * 4;
		rectVertices[baseIndex +  3] = left;
		rectVertices[baseIndex +  4] = bottom;
		
		rectVertices[baseIndex +  8] = left;
		rectVertices[baseIndex +  9] = top;
		
		rectVertices[baseIndex + 13] = right;
		rectVertices[baseIndex + 14] = top;
		
		rectVertices[baseIndex + 18] = right;
		rectVertices[baseIndex + 19] = bottom;
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
	
	public function drawImage(img: kha.Image, x: Float, y: Float): Void {
		var tex = cast(img, Texture);
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();
		
		var left: Float = x;
		var top: Float = y;
		var right: Float = x + img.width;
		var bottom: Float = y + img.height;
		
		setRectTexCoords(0, 0, tex.width / tex.realWidth, tex.height / tex.realHeight);
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = tex;
	}
	
	public function drawImage2(img: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float): Void {
		var tex = cast(img, Texture);
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();
		
		var left: Float = dx;
		var top: Float = dy;
		var right: Float = dx + dw;
		var bottom: Float = dy + dh;
		
		setRectTexCoords(sx / tex.realWidth, sy / tex.realHeight, (sx + sw) / tex.realWidth, (sy + sh) / tex.realHeight);
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = tex;
	}
	
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
		rectVertexBuffer = Sys.graphics.createVertexBuffer(bufferSize * 4, structure);
		rectVertices = rectVertexBuffer.lock();
		
		indexBuffer = Sys.graphics.createIndexBuffer(bufferSize * 3 * 2);
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
		
		triangleVertexBuffer = Sys.graphics.createVertexBuffer(triangleBufferSize * 3, structure);
		triangleVertices = triangleVertexBuffer.lock();
		
		triangleIndexBuffer = Sys.graphics.createIndexBuffer(triangleBufferSize * 3);
		var triIndices = triangleIndexBuffer.lock();
		for (i in 0...bufferSize) {
			triIndices[i * 3 + 0] = i * 3 + 0;
			triIndices[i * 3 + 1] = i * 3 + 1;
			triIndices[i * 3 + 2] = i * 3 + 2;
		}
		triangleIndexBuffer.unlock();
	}
	
	private function setRectVertices(left: Float, top: Float, right: Float, bottom: Float): Void {
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
	
	private function setRectColors(color: Color): Void {
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

	private function drawBuffer(): Void {
		endTris();
		
		rectVertexBuffer.unlock();
		Sys.graphics.setVertexBuffer(rectVertexBuffer);
		Sys.graphics.setIndexBuffer(indexBuffer);
		Sys.graphics.setProgram(shaderProgram);
		Sys.graphics.setMatrix(projectionLocation, projectionMatrix);
		
		Sys.graphics.drawIndexedVertices(0, bufferIndex * 2 * 3);

		bufferIndex = 0;
	}
	
	private function drawTriBuffer(): Void {
		endRects();
		
		triangleVertexBuffer.unlock();
		Sys.graphics.setVertexBuffer(triangleVertexBuffer);
		Sys.graphics.setIndexBuffer(triangleIndexBuffer);
		Sys.graphics.setProgram(shaderProgram);
		Sys.graphics.setMatrix(projectionLocation, projectionMatrix);
		
		Sys.graphics.drawIndexedVertices(0, triangleBufferIndex * 3);

		triangleBufferIndex = 0;
	}
	
	public function fillRect(color: Color, x: Float, y: Float, width: Float, height: Float): Void {
		if (bufferIndex + 1 >= bufferSize) drawBuffer();
		
		var left: Float = x;
		var top: Float = y;
		var right: Float = x + width;
		var bottom: Float = y + height;
		
		setRectColors(color);
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
	}
	
	public function fillTriangle(color: Color, x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		if (triangleBufferIndex + 1 >= triangleBufferSize) drawTriBuffer();
		
		setTriColors(color);
		setTriVertices(x1, y1, x2, y2, x3, y3);
		++triangleBufferIndex;
	}
	
	public function endTris(): Void {
		if (triangleBufferIndex > 0) drawTriBuffer();
	}
	
	public function endRects(): Void {
		if (bufferIndex > 0) drawBuffer();
	}
	
	public function end(): Void {
		endTris();
		endRects();
	}
}

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
		rectVertexBuffer = Sys.graphics.createVertexBuffer(bufferSize * 4, structure);
		rectVertices = rectVertexBuffer.lock();
		
		indexBuffer = Sys.graphics.createIndexBuffer(bufferSize * 3 * 2);
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
	
	public function drawString(text: String, color: Color, x: Float, y: Float): Void {
		var tex = font.getTexture();
		if (lastTexture != null && tex != lastTexture) drawBuffer();

		var xpos = x;
		var ypos = y;
		for (i in 0...text.length) {
			var q = font.getBakedQuad(text.charCodeAt(i) - 32, xpos, ypos);
			if (q != null) {
				if (bufferIndex + 1 >= bufferSize) drawBuffer();
				setRectColors(color);
				setRectTexCoords(q.s0 * tex.width / tex.realWidth, q.t0 * tex.height / tex.realHeight, q.s1 * tex.width / tex.realWidth, q.t1 * tex.height / tex.realHeight);
				setRectVertices(q.x0, q.y0, q.x1, q.y1);
				xpos += q.xadvance;
				++bufferIndex;
			}
		}
		lastTexture = tex;
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
	
	public function new(width: Int, height: Int) {
		color = Color.fromBytes(0, 0, 0);
		setScreenSize(width, height);
		imagePainter = new ImageShaderPainter(projectionMatrix);
		coloredPainter = new ColoredShaderPainter(projectionMatrix);
		textPainter = new TextShaderPainter(projectionMatrix);
	}
	
	public function setScreenSize(width: Int, height: Int) {
		projectionMatrix = ortho(0, width, height, 0, 0.1, 1000);
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
		imagePainter.drawImage(img, tx + x, ty + y);
	}
	
	public override function drawImage2(img: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float): Void {
		coloredPainter.end();
		textPainter.end();
		imagePainter.drawImage2(img, sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
	}
	
	public override function setColor(color: Color): Void {
		color = Color.fromBytes(color.Rb, color.Gb, color.Bb, color.Ab);
	}
	
	public override function drawRect(x: Float, y: Float, width: Float, height: Float): Void {
		coloredPainter.fillRect(color, tx + x, ty + y, width, 1);
		coloredPainter.fillRect(color, tx + x, ty + y, 1, height);
		coloredPainter.fillRect(color, tx + x, ty + y + height, width, 1);
		coloredPainter.fillRect(color, tx + x + width, ty + y, 1, height);
	}
	
	public override function fillRect(x: Float, y: Float, width: Float, height: Float): Void {
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

	public override function drawLine(x1: Float, y1: Float, x2: Float, y2: Float): Void {
		x1 += tx;
		y1 += ty;
		x2 += tx;
		y2 += ty;

		var vec: Vector2;
		if (y2 == y1) vec = new Vector2(0, -1);
		else vec = new Vector2(1, -(x2 - x1) / (y2 - y1));
		vec.length = 1;
		var vec1 = new Vector2(x1, y1);
		var vec2 = new Vector2(x2, y2);
		
		coloredPainter.fillTriangle(color, x1, y1, vec1.add(vec).x, vec1.add(vec).y, x2, y2);
		coloredPainter.fillTriangle(color, vec1.add(vec).x, vec1.add(vec).y, vec2.add(vec).x, vec2.add(vec).y, x2, y2);		
	}

	public override function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		coloredPainter.fillTriangle(color, tx + x1, ty + y1, tx + x2, ty + y2, tx + x3, ty + y3);
	}
	
	public override function begin(): Void {
		Sys.graphics.clear(kha.Color.fromBytes(0, 0, 0));
		translate(0, 0);
	}
	
	public override function end(): Void {
		imagePainter.end();
		coloredPainter.end();
		textPainter.end();
	}
}
