package com.ktxsoftware.kje.backends.android;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.opengl.Matrix;

import com.ktxsoftware.kje.Font;
import com.ktxsoftware.kje.Image;
import com.ktxsoftware.kje.Painter;

public class OpenGLPainter extends Painter {
    private int shaderProgram;
    private int vertexPositionAttribute, texCoordAttribute;
    private int triangleVertexBuffer, rectVertexBuffer, rectTexCoordBuffer;
    private FloatBuffer triangleVertices;
    private FloatBuffer rectVertices, rectTexCoords;//, rectVerticesCache, rectTexCoordsCache;
	private int textureUniform;
	private int indexBuffer;
	private IntBuffer indices;
	private final int bufferSize = 100;
	private int bufferIndex = 0;
	private Image lastTexture = null;
	private double tx, ty;
	private int matrixLocation;
	private float[] projectionMatrix;
	private int width, height;
	
	public OpenGLPainter(int width, int height) {
		this.width = width;
		this.height = height;
		mTriangleVertices = ByteBuffer.allocateDirect(30 * FLOAT_SIZE_BYTES * bufferSize).order(ByteOrder.nativeOrder()).asFloatBuffer();
		
		GLES20.glViewport(0, 0, width, height);
		
		initShaders();
		GLES20.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		GLES20.glClearDepthf(1.0f);
		GLES20.glEnable(GLES20.GL_BLEND);
		GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);
		initBuffers();
		
		projectionMatrix = new float[16];//ortho(0, width, height, 0, 0.1f, 1000);
		Matrix.orthoM(projectionMatrix, 0, 0, width, height, 0, 0.1f, 1000.0f);
		matrixLocation = GLES20.glGetUniformLocation(shaderProgram, "projectionMatrix");
		GLES20.glUniformMatrix4fv(matrixLocation, 1, false, projectionMatrix, 0);
	}
	
	private double getFactor() {
		if ((double)width / (double)height > (double)com.ktxsoftware.kje.Game.getInstance().getWidth() / (double)com.ktxsoftware.kje.Game.getInstance().getHeight())
			return (double)height / (double)com.ktxsoftware.kje.Game.getInstance().getHeight();
		else
			return (double)width / (double)com.ktxsoftware.kje.Game.getInstance().getWidth();
	}
	
	private double getXOffset() {
		if ((double)width / (double)height > (double)com.ktxsoftware.kje.Game.getInstance().getWidth() / (double)com.ktxsoftware.kje.Game.getInstance().getHeight())
			return width / 2 - com.ktxsoftware.kje.Game.getInstance().getWidth() * getFactor() / 2;
		else
			return 0;
	}
	
	private double getYOffset() {
		if ((double)width / (double)height > (double)com.ktxsoftware.kje.Game.getInstance().getWidth() / (double)com.ktxsoftware.kje.Game.getInstance().getHeight())
			return 0;
		else
			return height / 2 - com.ktxsoftware.kje.Game.getInstance().getHeight() * getFactor() / 2;
	}
	
	private double adjustX(double x) {
		return x * getFactor();
	}
	
	private double adjustY(double y) {
		return y * getFactor();
	}
	
	public double adjustXPos(double x) {
		return adjustX(x) + getXOffset();
	}
	
	public double adjustYPos(double y) {
		return adjustY(y) + getYOffset();
	}
	
	public double adjustXPosInv(double x) {
		return (x - getXOffset()) / getFactor();
	}
	
	public double adjustYPosInv(double y) {
		return (y - getYOffset()) / getFactor();
	}
	
	private void initShaders() {
		int fragmentShader = getShader(GLES20.GL_FRAGMENT_SHADER,
				  "#ifdef GL_ES\n"
				+ "precision highp float;\n"
				+ "#endif\n\n"
				+ "uniform sampler2D tex;"
				+ "varying vec2 texCoord;"
				+ "void main() {"
				+ "gl_FragColor = texture2D(tex, texCoord);"
				+ "}");
		
		int vertexShader = getShader(GLES20.GL_VERTEX_SHADER,
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
	
	private int getShader(int type, String source) {
		int shader = GLES20.glCreateShader(type);
		GLES20.glShaderSource(shader, source);
		GLES20.glCompileShader(shader);

		//**if (!gl.getShaderParameterb(shader, WebGLRenderingContext.COMPILE_STATUS)) throw new RuntimeException(gl.getShaderInfoLog(shader));

		return shader;
	}
	
	private int createBuffer() {
		int buffers[] = new int[1];
		GLES20.glGenBuffers(1, buffers, 0);
		return buffers[0];
	}
	
	private void initBuffers() {
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
		
		for (int i = 0; i < bufferSize; ++i) {
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
	
	@SuppressWarnings("unused")
	private float[] ortho(float left, float right, float bottom, float top, float zn, float zf) {
		float tx = -(right + left) / (right - left);
		float ty = -(top + bottom) / (top - bottom);
		float tz = -(zf + zn) / (zf - zn);
		return new float[] {
			2 / (right - left), 0,                  0,              0,
			0,                  2 / (top - bottom), 0,              0,
			0,                  0,                  -2 / (zf - zn), 0,
			tx,                 ty,                 tz,             1
		};
	}
	
	private void checkErrors() {
		int error = GLES20.glGetError();
		if (error != GLES20.GL_NO_ERROR) {
			System.err.println("GL error");
		}
	}
	
	@SuppressWarnings("unused")
	private void setRectVertices(float left, float top, float right, float bottom) {
		int baseIndex = bufferIndex * 3 * 4;
		rectVertices.put(baseIndex + 0, left  );
		rectVertices.put(baseIndex + 1, bottom   );
		rectVertices.put(baseIndex + 2, -5.0f);
		rectVertices.put(baseIndex + 3, left );
		rectVertices.put(baseIndex + 4, top   );
		rectVertices.put(baseIndex + 5, -5.0f );
		rectVertices.put(baseIndex + 6, right  );
		rectVertices.put(baseIndex + 7, top);
		rectVertices.put(baseIndex + 8, -5.0f );
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
	
	@SuppressWarnings("unused")
	private void setRectTexCoords(float left, float top, float right, float bottom) {
		int baseIndex = bufferIndex * 2 * 4;
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
	
	private int createTexture() {
		int[] textures = new int[1];
		GLES20.glGenTextures(1, textures, 0);
		return textures[0];
	}

	private void setTexture(BitmapImage img) {
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
	
	private void drawBuffer() {
		//java.lang.System.err.println("drawBuffer " + bufferIndex);
		setTexture((BitmapImage)lastTexture);
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
	
	@Override
	public void drawImage(Image img, double x, double y) {
		drawImage(img, 0, 0, img.getWidth(), img.getHeight(), x, y, img.getWidth(), img.getHeight());
	}
	
	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
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
		
		float x1 = (float)adjustXPos(dx + tx);
		float y1 = (float)adjustYPos(dy + ty);
		float x2 = (float)adjustXPos(dx + dw + tx);
		float y2 = (float)adjustYPos(dy + dh + ty);
		
		float u1 = (float)(sx / img.getWidth());
		float v1 = (float)(sy / img.getHeight());
		float u2 = (float)((sx + sw) / img.getWidth());
		float v2 = (float)((sy + sh) / img.getHeight());
		
		//mTriangleVertices.position(0);
		mTriangleVertices.put(x1); mTriangleVertices.put(y1); mTriangleVertices.put(-1.0f); mTriangleVertices.put(u1); mTriangleVertices.put(v1);
		mTriangleVertices.put(x2); mTriangleVertices.put(y1); mTriangleVertices.put(-1.0f); mTriangleVertices.put(u2); mTriangleVertices.put(v1);
		mTriangleVertices.put(x1); mTriangleVertices.put(y2); mTriangleVertices.put(-1.0f); mTriangleVertices.put(u1); mTriangleVertices.put(v2);
		
		mTriangleVertices.put(x2); mTriangleVertices.put(y1); mTriangleVertices.put(-1.0f); mTriangleVertices.put(u2); mTriangleVertices.put(v1);
		mTriangleVertices.put(x2); mTriangleVertices.put(y2); mTriangleVertices.put(-1.0f); mTriangleVertices.put(u2); mTriangleVertices.put(v2);
		mTriangleVertices.put(x1); mTriangleVertices.put(y2); mTriangleVertices.put(-1.0f); mTriangleVertices.put(u1); mTriangleVertices.put(v2);
		
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
	
	@Override
	public void setColor(int r, int g, int b) {
		//context.setStrokeStyle(CssColor.make(r, g, b));
		//context.setFillStyle(CssColor.make(r, g, b));
	}
	
	@Override
	public void drawRect(double x, double y, double width, double height) {
		//context.rect(tx + x, ty + y, width, height);
	}
	
	@Override
	public void fillRect(double x, double y, double width, double height) {
		//context.fillRect(tx + x, ty + y, width, height);
	}

	@Override
	public void translate(double x, double y) {
		tx = x;
		ty = y;
	}

	@Override
	public void drawString(String text, double x, double y) {
		//context.fillText(text, tx + x, ty + y);
	}

	@Override
	public void setFont(Font font) {
		//context.setFont(((WebFont)font).name);
	}

	@Override
	public void drawChars(char[] text, int offset, int length, double x, double y) {
		drawString(new String(text, offset, length), x, y);
	}

	@Override
	public void drawLine(double x1, double y1, double x2, double y2) {
		/*context.moveTo(tx + x1, ty + y1);
		context.lineTo(tx + x2, ty + y2);
		context.moveTo(0, 0);*/
	}

	@Override
	public void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3) {
		/*context.beginPath();
		
		context.closePath();
		context.fill();*/
	}
	
	@Override
	public void begin() {
		GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_COLOR_BUFFER_BIT);
	}
	
	@Override
	public void end() {
		if (bufferIndex > 0) drawBuffer();
		lastTexture = null;
	}
	
	private static final int FLOAT_SIZE_BYTES = 4;
	private static final int TRIANGLE_VERTICES_DATA_STRIDE_BYTES = 5 * FLOAT_SIZE_BYTES;
	private static final int TRIANGLE_VERTICES_DATA_POS_OFFSET = 0;
	private static final int TRIANGLE_VERTICES_DATA_UV_OFFSET = 3;
	private FloatBuffer mTriangleVertices;
}