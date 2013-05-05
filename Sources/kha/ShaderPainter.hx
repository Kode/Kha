package kha;

import kha.graphics.ConstantLocation;
import kha.graphics.IndexBuffer;
import kha.graphics.Program;
import kha.graphics.Texture;
import kha.graphics.TextureUnit;
import kha.graphics.VertexBuffer;
import kha.graphics.VertexData;
import kha.graphics.VertexStructure;
import kha.graphics.VertexType;

class ShaderPainter extends Painter {
    var shaderProgram: Program;
    var vertexPositionAttribute : Int;
	var texCoordAttribute : Int;
    //var triangleVertexBuffer: VertexBuffer;
	var rectVertexBuffer: VertexBuffer;
	//var triangleVertices : Dynamic;
    var rectVertices: Array<Float>;
	//var textureUniform : Dynamic;
	var indexBuffer: IndexBuffer;
	static var bufferSize: Int = 100;
	var bufferIndex: Int;
	var lastTexture: Texture;
	var tx: Float;
	var ty: Float;
	private var structure: VertexStructure;
	private var projectionLocation: ConstantLocation;
	private var projectionMatrix: Array<Float>;
	private var textureLocation: TextureUnit;
	
	public function new(width: Int, height: Int) {
		initShaders();
		
		initBuffers();

		setScreenSize(width, height);
		projectionLocation = shaderProgram.getConstantLocation("projectionMatrix");
		textureLocation = shaderProgram.getTextureUnit("tex");
	}
	
	public function setScreenSize(width: Int, height: Int) {
		projectionMatrix = ortho(0, width, height, 0, 0.1, 1000);
	}
	
	private function initShaders(): Void {
		var fragmentShader = Sys.graphics.createFragmentShader(Loader.the.getShader("painter.frag"));
		var vertexShader = Sys.graphics.createVertexShader(Loader.the.getShader("painter.vert"));
	
		shaderProgram = Sys.graphics.createProgram();
		shaderProgram.setFragmentShader(fragmentShader);
		shaderProgram.setVertexShader(vertexShader);

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3, VertexType.Position);
		structure.add("texPosition", VertexData.Float2, VertexType.TexCoord);
		
		shaderProgram.link(structure);
		/*
		gl.useProgram(shaderProgram);
		
		vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "vertexPosition");
		gl.enableVertexAttribArray(vertexPositionAttribute);
		
		texCoordAttribute = gl.getAttribLocation(shaderProgram, "texPosition");
		gl.enableVertexAttribArray(texCoordAttribute);
		
		textureUniform = gl.getUniformLocation(shaderProgram, "tex");
		gl.uniform1i(textureUniform, 0);
		*/
	}
	
	function initBuffers(): Void {
		//triangleVertexBuffer = Sys.graphics.createVertexBuffer(3, structure);
		
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

	private function setTexture(img: Image) : Void {
		Sys.graphics.setTexture(textureLocation, img);
	}
	
	private function drawBuffer(): Void {
		setTexture(lastTexture);
		
		rectVertexBuffer.unlock();
		Sys.graphics.setVertexBuffer(rectVertexBuffer);
		Sys.graphics.setIndexBuffer(indexBuffer);
		Sys.graphics.setProgram(shaderProgram);
		Sys.graphics.setMatrix(projectionLocation, projectionMatrix);
		
		Sys.graphics.drawIndexedVertices(0, bufferIndex * 2 * 3);

		bufferIndex = 0;
	}
	
	public override function drawImage(img: kha.Image, x: Float, y: Float) : Void {
		var tex = cast(img, Texture);
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();
		
		var left: Float = tx + x;
		var top: Float = ty + y;
		var right: Float = tx + x + img.width;
		var bottom: Float = ty + y + img.height;
		
		setRectTexCoords(0, 0, tex.width / tex.realWidth, tex.height / tex.realHeight);
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = tex;
	}
	
	public override function drawImage2(img: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float): Void {
		var tex = cast(img, Texture);
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && tex != lastTexture)) drawBuffer();
		
		var left: Float = tx + dx;
		var top: Float = ty + dy;
		var right: Float = tx + dx + dw;
		var bottom: Float = ty + dy + dh;
		
		setRectTexCoords(sx / tex.realWidth, sy / tex.realHeight, (sx + sw) / tex.realWidth, (sy + sh) / tex.realHeight);
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = tex;
	}
	
	public override function setColor(r : Int, g : Int, b : Int) : Void {
		//context.setStrokeStyle(CssColor.make(r, g, b));
		//context.setFillStyle(CssColor.make(r, g, b));
	}
	
	public override function drawRect(x : Float, y : Float, width : Float, height : Float) : Void {
		//context.rect(tx + x, ty + y, width, height);
	}
	
	public override function fillRect(x : Float, y : Float, width : Float, height : Float) : Void {
		//context.fillRect(tx + x, ty + y, width, height);
	}

	public override function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}

	public override function drawString(text : String, x : Float, y : Float) : Void {
		//context.fillText(text, tx + x, ty + y);
	}

	public override function setFont(font : Font) : Void {
		//context.setFont(((WebFont)font).name);
	}

	//public override function drawChars(text : String, offset : Int, length : Int, x : Float, y : Float) : Void {
	//	drawString(new String(text, offset, length), x, y);
	//}

	public override function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Void {
		/*context.moveTo(tx + x1, ty + y1);
		context.lineTo(tx + x2, ty + y2);
		context.moveTo(0, 0);*/
	}

	public override function fillTriangle(x1 : Float, y1 : Float, x2 : Float, y2 : Float, x3 : Float, y3 : Float) {
		/*context.beginPath();
		
		context.closePath();
		context.fill();*/
	}
	
	public override function begin() : Void {
		//gl.clearColor(0, 0, 0, 255);
		//gl.clear(gl.COLOR_BUFFER_BIT);// | WebGLRenderingContext.DEPTH_BUFFER_BIT);
	}
	
	public override function end() : Void {
		if (bufferIndex > 0) drawBuffer();
		lastTexture = null;
		//gl.flush();
	}
}
