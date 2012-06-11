package kha.android;

import java.NativeArray;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.opengl.Matrix;

class OpenGLPainter extends kha.Painter {
    var shaderProgram : Int;
    var vertexPositionAttribute : Int;
	var texCoordAttribute : Int;
    var triangleVertexBuffer : Int;
	var rectVertexBuffer : Int;
	var rectTexCoordBuffer : Int;
    var triangleVertices : FloatBuffer;
    var rectVertices : FloatBuffer;
	var rectTexCoords : FloatBuffer;//, rectVerticesCache, rectTexCoordsCache;
	var textureUniform : Int;
	var indexBuffer : Int;
	var indices : IntBuffer;
	static var bufferSize : Int = 100;
	var bufferIndex : Int = 0;
	var lastTexture : kha.Image = null;
	var tx : Float;
	var ty : Float;
	var matrixLocation : Int;
	var projectionMatrix : NativeArray<Single>;
	var width : Int;
	var height : Int;
	
	public function new(width : Int, height : Int) {
		this.width = width;
		this.height = height;
		mTriangleVertices = ByteBuffer.allocateDirect(30 * FLOAT_SIZE_BYTES * bufferSize).order(ByteOrder.nativeOrder()).asFloatBuffer();
		
		GLES20.glViewport(0, 0, width, height);
		
		initShaders();
		GLES20.glClearColor(0.0, 0.0, 0.0, 1.0);
		GLES20.glClearDepthf(1.0);
		GLES20.glEnable(GLES20.GL_BLEND);
		GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);
		initBuffers();
		
		projectionMatrix = new NativeArray<Single>(16);
		Matrix.orthoM(projectionMatrix, 0, 0, width, height, 0, 0.1, 1000.0);
		matrixLocation = GLES20.glGetUniformLocation(shaderProgram, "projectionMatrix");
		GLES20.glUniformMatrix4fv(matrixLocation, 1, false, projectionMatrix, 0);
	}
	
	function getFactor() : Float {
		if (width / height > kha.Game.getInstance().getWidth() / kha.Game.getInstance().getHeight())
			return height / kha.Game.getInstance().getHeight();
		else
			return width / kha.Game.getInstance().getWidth();
	}
	
	function getXOffset() : Float {
		if (width / height > kha.Game.getInstance().getWidth() / kha.Game.getInstance().getHeight())
			return width / 2 - kha.Game.getInstance().getWidth() * getFactor() / 2;
		else
			return 0;
	}
	
	function getYOffset() : Float {
		if (width / height > kha.Game.getInstance().getWidth() / kha.Game.getInstance().getHeight())
			return 0;
		else
			return height / 2 - kha.Game.getInstance().getHeight() * getFactor() / 2;
	}
	
	function adjustX(x : Float) : Float {
		return x * getFactor();
	}
	
	function adjustY(y : Float) : Float {
		return y * getFactor();
	}
	
	public function adjustXPos(x : Float) : Float {
		return adjustX(x) + getXOffset();
	}
	
	public function adjustYPos(y : Float) : Float {
		return adjustY(y) + getYOffset();
	}
	
	public function adjustXPosInv(x : Float) : Float {
		return (x - getXOffset()) / getFactor();
	}
	
	public function adjustYPosInv(y : Float) : Float {
		return (y - getYOffset()) / getFactor();
	}
	
	function initShaders() : Void {
		var fragmentShader = getShader(GLES20.GL_FRAGMENT_SHADER,
				  "#ifdef GL_ES\n"
				+ "precision highp float;\n"
				+ "#endif\n\n"
				+ "uniform sampler2D tex;"
				+ "varying vec2 texCoord;"
				+ "void main() {"
				+ "gl_FragColor = texture2D(tex, texCoord);"
				+ "}");
		
		var vertexShader = getShader(GLES20.GL_VERTEX_SHADER,
				  "attribute vec3 vertexPosition;"
				+ "attribute vec2 texPosition;"
				+ "uniform mat4 projectionMatrix;"
				+ "varying vec2 texCoord;"
				+ "void main() {"
				+ "gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);"
				+ "texCoord = texPosition;"
				+ "}");
	
		shaderProgram = GLES20.glCreateProgram();
		GLES20.glAttachShader(shaderProgram, vertexShader);
		GLES20.glAttachShader(shaderProgram, fragmentShader);
		
		GLES20.glBindAttribLocation(shaderProgram, 0, "vertexPosition");
		GLES20.glBindAttribLocation(shaderProgram, 1, "texPosition");

		GLES20.glLinkProgram(shaderProgram);

		//**if (!gl.getProgramParameterb(shaderProgram, WebGLRenderingContext.LINK_STATUS)) throw new RuntimeException("Could not initialise shaders");

		GLES20.glUseProgram(shaderProgram);
		
		vertexPositionAttribute = GLES20.glGetAttribLocation(shaderProgram, "vertexPosition");
		GLES20.glEnableVertexAttribArray(vertexPositionAttribute);
		
		texCoordAttribute = GLES20.glGetAttribLocation(shaderProgram, "texPosition");
		GLES20.glEnableVertexAttribArray(texCoordAttribute);
		
		textureUniform = GLES20.glGetUniformLocation(shaderProgram, "tex");
		GLES20.glUniform1i(textureUniform, 0);
		
		//checkErrors();
	}
	
	function getShader(type : Int, source : String) : Int {
		var shader = GLES20.glCreateShader(type);
		GLES20.glShaderSource(shader, source);
		GLES20.glCompileShader(shader);

		//**if (!gl.getShaderParameterb(shader, WebGLRenderingContext.COMPILE_STATUS)) throw new RuntimeException(gl.getShaderInfoLog(shader));

		return shader;
	}
	
	function createBuffer() : Int {
		var buffers = new NativeArray<Int>(1);
		GLES20.glGenBuffers(1, buffers, 0);
		return buffers[0];
	}
	
	function initBuffers() : Void {
		triangleVertexBuffer = createBuffer();
		GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, triangleVertexBuffer);
		triangleVertices = ByteBuffer.allocateDirect(3 * 3 * FLOAT_SIZE_BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
		GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, triangleVertices.capacity() * FLOAT_SIZE_BYTES, triangleVertices, GLES20.GL_DYNAMIC_DRAW);
		
		rectVertexBuffer = createBuffer();
		GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, rectVertexBuffer);
		rectVertices = ByteBuffer.allocateDirect(bufferSize * 3 * 4 * FLOAT_SIZE_BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
		GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, rectVertices.capacity() * FLOAT_SIZE_BYTES, rectVertices, GLES20.GL_DYNAMIC_DRAW);
		GLES20.glVertexAttribPointer(vertexPositionAttribute, 3, GLES20.GL_FLOAT, false, 0, rectVertices);
		//rectVerticesCache = Float32Array.create(3 * 6);
		
		rectTexCoordBuffer = createBuffer();
		GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, rectTexCoordBuffer);
		rectTexCoords = ByteBuffer.allocateDirect(bufferSize * 2 * 4 * FLOAT_SIZE_BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
		GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, rectTexCoords.capacity(), rectTexCoords, GLES20.GL_DYNAMIC_DRAW);
		GLES20.glVertexAttribPointer(texCoordAttribute, 2, GLES20.GL_FLOAT, false, 0, rectTexCoords);
		//rectTexCoordsCache = Float32Array.create(2 * 6);
		
		indexBuffer = createBuffer();
		GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
		indices = ByteBuffer.allocateDirect(bufferSize * 3 * 4 * FLOAT_SIZE_BYTES).order(ByteOrder.nativeOrder()).asIntBuffer();
		
		for (i in 0...bufferSize) {
			indices.put(i * 3 * 2 + 0, i * 4 + 0);
			indices.put(i * 3 * 2 + 1, i * 4 + 1);
			indices.put(i * 3 * 2 + 2, i * 4 + 2);
			indices.put(i * 3 * 2 + 3, i * 4 + 0);
			indices.put(i * 3 * 2 + 4, i * 4 + 2);
			indices.put(i * 3 * 2 + 5, i * 4 + 3);
		}
		
		GLES20.glBufferData(GLES20.GL_ELEMENT_ARRAY_BUFFER, indices.capacity() * 4, indices, GLES20.GL_STATIC_DRAW);
		
		GLES20.glEnableVertexAttribArray(vertexPositionAttribute);
		GLES20.glEnableVertexAttribArray(texCoordAttribute);
		
		GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0);
		GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, 0);
		
		checkErrors();
	}
	
	//@SuppressWarnings("unused")
	function ortho(left : Float, right : Float, bottom : Float, top : Float, zn : Float, zf : Float) : Array<Float> {
		var tx = -(right + left) / (right - left);
		var ty = -(top + bottom) / (top - bottom);
		var tz = -(zf + zn) / (zf - zn);
		return [
			2 / (right - left), 0,                  0,              0,
			0,                  2 / (top - bottom), 0,              0,
			0,                  0,                  -2 / (zf - zn), 0,
			tx,                 ty,                 tz,             1
		];
	}
	
	function checkErrors() : Void {
		var error = GLES20.glGetError();
		if (error != GLES20.GL_NO_ERROR) {
			trace("GL error");
		}
	}
	
	//@SuppressWarnings("unused")
	function setRectVertices(left : Single, top : Single, right : Single, bottom : Single) {
		var baseIndex = bufferIndex * 3 * 4;
		rectVertices.put(baseIndex + 0, left  );
		rectVertices.put(baseIndex + 1, bottom   );
		rectVertices.put(baseIndex + 2, cast(-5.0, Single));
		rectVertices.put(baseIndex + 3, left );
		rectVertices.put(baseIndex + 4, top   );
		rectVertices.put(baseIndex + 5, cast(-5.0, Single));
		rectVertices.put(baseIndex + 6, right  );
		rectVertices.put(baseIndex + 7, top);
		rectVertices.put(baseIndex + 8, cast(-5.0, Single));
		rectVertices.put(baseIndex + 9, right  );
		rectVertices.put(baseIndex +10, bottom);
		/*rectVertices.set(baseIndex +11, -5.0f );
		rectVertices.set(baseIndex +12, right );
		rectVertices.set(baseIndex +13, top   );
		rectVertices.set(baseIndex +14, -5.0f );
		rectVertices.set(baseIndex +15, right );
		rectVertices.set(baseIndex +16, bottom);*/
		
		//gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectVertexBuffer);
		//gl.bufferSubData(WebGLRenderingContext.ARRAY_BUFFER, bufferIndex * 3 * 6 * 4, rectVerticesCache);
	}
	
	//@SuppressWarnings("unused")
	function setRectTexCoords(left : Single, top : Single, right : Single, bottom : Single) {
		var baseIndex = bufferIndex * 2 * 4;
		rectTexCoords.put(baseIndex + 0, left  );
		rectTexCoords.put(baseIndex + 1, bottom   );
		rectTexCoords.put(baseIndex + 2, left );
		rectTexCoords.put(baseIndex + 3, top   );
		rectTexCoords.put(baseIndex + 4, right  );
		rectTexCoords.put(baseIndex + 5, top);
		rectTexCoords.put(baseIndex + 6, right  );
		rectTexCoords.put(baseIndex + 7, bottom);
		/*rectTexCoords.set(baseIndex + 8, right );
		rectTexCoords.set(baseIndex + 9, top   );
		rectTexCoords.set(baseIndex +10, right );
		rectTexCoords.set(baseIndex +11, bottom);*/
		
		//gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectTexCoordBuffer);
		//gl.bufferSubData(WebGLRenderingContext.ARRAY_BUFFER, bufferIndex * 2 * 6 * 4, rectTexCoordsCache);
	}
	
	function createTexture() : Int {
		var textures = new NativeArray<Int>(1);
		GLES20.glGenTextures(1, textures, 0);
		return textures[0];
	}

	function setTexture(img : Image) : Void {
		if (img.tex == -1) {
			img.tex = createTexture();
			GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, img.tex);
			//glContext.pixelStorei(WebGLRenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_NEAREST);
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
			GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, img.getBitmap(), 0);
			//GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, img.getWidth(), img.getHeight(), 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, img.getBuffer());
			//GLES20.glUniform1i(textureUniform, GLES20.GL_TEXTURE0);
		}
		else GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, img.tex);
	}
	
	function drawBuffer() : Void {
		//java.lang.System.err.println("drawBuffer " + bufferIndex);
		setTexture(cast(lastTexture, Image));
		/*GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, rectVertexBuffer);
		GLES20.glBufferSubData(GLES20.GL_ARRAY_BUFFER, 0, bufferIndex * 4 * 3, rectVertices);
		GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, rectTexCoordBuffer);
		GLES20.glBufferSubData(GLES20.GL_ARRAY_BUFFER, 0, bufferIndex * 4 * 2, rectTexCoords);
		GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
		
		//GLES20.glDrawElements(GLES20.GL_TRIANGLES, bufferIndex * 2 * 3, GLES20.GL_UNSIGNED_SHORT, indices);
		GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, bufferIndex * 6);
		bufferIndex = 0;
		//checkErrors();*/
		
		mTriangleVertices.position(TRIANGLE_VERTICES_DATA_POS_OFFSET);
		GLES20.glVertexAttribPointer(vertexPositionAttribute, 3, GLES20.GL_FLOAT, false, TRIANGLE_VERTICES_DATA_STRIDE_BYTES, mTriangleVertices);
		mTriangleVertices.position(TRIANGLE_VERTICES_DATA_UV_OFFSET);
		GLES20.glEnableVertexAttribArray(vertexPositionAttribute);
		GLES20.glVertexAttribPointer(texCoordAttribute, 2, GLES20.GL_FLOAT, false, TRIANGLE_VERTICES_DATA_STRIDE_BYTES, mTriangleVertices);
		GLES20.glEnableVertexAttribArray(texCoordAttribute);

		GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, 3 * 2 * bufferIndex);

		mTriangleVertices.position(0);
		bufferIndex = 0;
	}
	
	override public function drawImage(img : kha.Image, x : Float, y : Float) : Void {
		drawImage2(img, 0, 0, img.getWidth(), img.getHeight(), x, y, img.getWidth(), img.getHeight());
	}
	
	function bla(blub : Single) {
		
	}
	
	override public function drawImage2(img : kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && img != lastTexture)) drawBuffer();
		
		/*float left = (float)(tx + dx);
		float top = (float)(ty + dy);
		float right = (float)(tx + dx + dw);
		float bottom = (float)(ty + dy + dh);
		
		setRectTexCoords((float)(sx / img.getWidth()), (float)(sy / img.getHeight()), (float)((sx + sw) / img.getWidth()), (float)((sy + sh) / img.getHeight()));
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = img;*/
		
		//setTexture((BitmapImage)img);
		
		var x1 : Single = adjustXPos(dx + tx);
		var y1 : Single = adjustYPos(dy + ty);
		var x2 : Single = adjustXPos(dx + dw + tx);
		var y2 : Single = adjustYPos(dy + dh + ty);
		
		var u1 : Single = sx / img.getWidth();
		var v1 : Single = sy / img.getHeight();
		var u2 : Single = (sx + sw) / img.getWidth();
		var v2 : Single = (sy + sh) / img.getHeight();
		
		//mTriangleVertices.position(0);
		mTriangleVertices.put(x1); mTriangleVertices.put(y1); mTriangleVertices.put(cast(-1.0, Single)); mTriangleVertices.put(u1); mTriangleVertices.put(v1);
		mTriangleVertices.put(x2); mTriangleVertices.put(y1); mTriangleVertices.put(cast(-1.0, Single)); mTriangleVertices.put(u2); mTriangleVertices.put(v1);
		mTriangleVertices.put(x1); mTriangleVertices.put(y2); mTriangleVertices.put(cast(-1.0, Single)); mTriangleVertices.put(u1); mTriangleVertices.put(v2);
		
		mTriangleVertices.put(x2); mTriangleVertices.put(y1); mTriangleVertices.put(cast(-1.0, Single)); mTriangleVertices.put(u2); mTriangleVertices.put(v1);
		mTriangleVertices.put(x2); mTriangleVertices.put(y2); mTriangleVertices.put(cast(-1.0, Single)); mTriangleVertices.put(u2); mTriangleVertices.put(v2);
		mTriangleVertices.put(x1); mTriangleVertices.put(y2); mTriangleVertices.put(cast(-1.0, Single)); mTriangleVertices.put(u1); mTriangleVertices.put(v2);
		
		++bufferIndex;
		lastTexture = img;
		
		/*mTriangleVertices.position(TRIANGLE_VERTICES_DATA_POS_OFFSET);
        GLES20.glVertexAttribPointer(vertexPositionAttribute, 3, GLES20.GL_FLOAT, false, TRIANGLE_VERTICES_DATA_STRIDE_BYTES, mTriangleVertices);
        mTriangleVertices.position(TRIANGLE_VERTICES_DATA_UV_OFFSET);
        GLES20.glEnableVertexAttribArray(vertexPositionAttribute);
        GLES20.glVertexAttribPointer(texCoordAttribute, 2, GLES20.GL_FLOAT, false, TRIANGLE_VERTICES_DATA_STRIDE_BYTES, mTriangleVertices);
        GLES20.glEnableVertexAttribArray(texCoordAttribute);

        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, 3 * 2);*/
	}
	
	override public function setColor(r : Int, g : Int, b : Int) : Void {
		//context.setStrokeStyle(CssColor.make(r, g, b));
		//context.setFillStyle(CssColor.make(r, g, b));
	}
	
	override public function drawRect(x : Float, y : Float, width : Float, height : Float) : Void {
		//context.rect(tx + x, ty + y, width, height);
	}
	
	override public function fillRect(x : Float, y : Float, width : Float, height : Float) : Void {
		//context.fillRect(tx + x, ty + y, width, height);
	}

	override public function translate(x : Float, y : Float) : Void {
		tx = x;
		ty = y;
	}

	override public function drawString(text : String, x : Float, y : Float) : Void {
		//context.fillText(text, tx + x, ty + y);
	}

	override public function setFont(font : kha.Font) : Void {
		//context.setFont(((WebFont)font).name);
	}

	override public function drawChars(text : String, offset : Int, length : Int, x : Float, y : Float) {
		drawString(text.substr(offset, length), x, y);
	}

	override public function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Void {
		/*context.moveTo(tx + x1, ty + y1);
		context.lineTo(tx + x2, ty + y2);
		context.moveTo(0, 0);*/
	}

	override public function fillTriangle(x1 : Float, y1 : Float, x2 : Float, y2 : Float, x3 : Float, y3 : Float) : Void {
		/*context.beginPath();
		
		context.closePath();
		context.fill();*/
	}
	
	override public function begin() {
		GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_COLOR_BUFFER_BIT);
	}
	
	override public function end() {
		if (bufferIndex > 0) drawBuffer();
		lastTexture = null;
	}
	
	static var FLOAT_SIZE_BYTES = 4;
	static var TRIANGLE_VERTICES_DATA_STRIDE_BYTES = 5 * FLOAT_SIZE_BYTES;
	static var TRIANGLE_VERTICES_DATA_POS_OFFSET = 0;
	static var TRIANGLE_VERTICES_DATA_UV_OFFSET = 3;
	var mTriangleVertices : FloatBuffer;
}