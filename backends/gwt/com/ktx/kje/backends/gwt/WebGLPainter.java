package com.ktx.kje.backends.gwt;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.ui.FocusPanel;
import com.googlecode.gwtgl.array.Float32Array;
import com.googlecode.gwtgl.array.Uint16Array;
import com.googlecode.gwtgl.binding.WebGLBuffer;
import com.googlecode.gwtgl.binding.WebGLCanvas;
import com.googlecode.gwtgl.binding.WebGLProgram;
import com.googlecode.gwtgl.binding.WebGLRenderingContext;
import com.googlecode.gwtgl.binding.WebGLShader;
import com.googlecode.gwtgl.binding.WebGLUniformLocation;
import com.ktx.kje.Font;
import com.ktx.kje.Image;
import com.ktx.kje.Painter;

public class WebGLPainter implements Painter {
	@SuppressWarnings("unused")
	private int width, height;
	
	private WebGLRenderingContext gl;
    private WebGLProgram shaderProgram;
    private int vertexPositionAttribute, texCoordAttribute;
    private WebGLBuffer triangleVertexBuffer, rectVertexBuffer, rectTexCoordBuffer;
    private Float32Array triangleVertices;
    private Float32Array rectVertices, rectTexCoords;//, rectVerticesCache, rectTexCoordsCache;
	private WebGLUniformLocation textureUniform;
	private WebGLBuffer indexBuffer;
	private final int bufferSize = 100;
	private int bufferIndex = 0;
	private Image lastTexture = null;
	private double tx, ty;
	
	public WebGLPainter(FocusPanel panel, int width, int height) {
		this.width = width;
		this.height = height;
		
		final WebGLCanvas webGLCanvas = new WebGLCanvas(width + "px", height + "px");
		gl = webGLCanvas.getGlContext();
		gl.viewport(0, 0, width, height);
		panel.add(webGLCanvas);
		
		initShaders();
		gl.clearColor(1.0f, 1.0f, 1.0f, 1.0f);
		gl.clearDepth(1.0f);
		//glContext.enable(WebGLRenderingContext.DEPTH_TEST);
		//glContext.enable(WebGLRenderingContext.TEXTURE_2D);
		//glContext.depthFunc(WebGLRenderingContext.LEQUAL);
		gl.enable(WebGLRenderingContext.BLEND);
		gl.blendFunc(WebGLRenderingContext.SRC_ALPHA, WebGLRenderingContext.ONE_MINUS_SRC_ALPHA);
		initBuffers();

		float[] projectionMatrix = ortho(0, width, height, 0, 0.1f, 1000);
		WebGLUniformLocation uniformLocation = gl.getUniformLocation(shaderProgram, "projectionMatrix");
		gl.uniformMatrix4fv(uniformLocation, false, projectionMatrix);
		
		//checkErrors();
	}
	
	private void initShaders() {
		WebGLShader fragmentShader = getShader(WebGLRenderingContext.FRAGMENT_SHADER,
				  "#ifdef GL_ES\n"
				+ "precision highp float;\n"
				+ "#endif\n\n"
				+ "uniform sampler2D tex;"
				+ "varying vec2 texCoord;"
				+ "void main() {"
				//+ "gl_FragColor = vec4(1.0,1.0,1.0,1.0);"
				//+ "vec4 color = texture2D(tex, texCoord);"
		        //+ "color += vec4(0.1, 0.1, 0.1, 1);"
		        //+ "gl_FragColor = color;" //vec4(color.xyz * v_Dot, color.a);
				+ "gl_FragColor = texture2D(tex, texCoord);"
				+ "}");
		
		WebGLShader vertexShader = getShader(WebGLRenderingContext.VERTEX_SHADER,
				  "attribute vec3 vertexPosition;"
				+ "attribute vec2 texPosition;"
				+ "uniform mat4 projectionMatrix;"
				+ "varying vec2 texCoord;"
				+ "void main() {"
				+ "gl_Position = projectionMatrix * vec4(vertexPosition, 1.0);"
				+ "texCoord = texPosition;"
				+ "}");
	
		shaderProgram = gl.createProgram();
		gl.attachShader(shaderProgram, vertexShader);
		gl.attachShader(shaderProgram, fragmentShader);
		
		gl.bindAttribLocation(shaderProgram, 0, "vertexPosition");
		gl.bindAttribLocation(shaderProgram, 1, "texPosition");

		gl.linkProgram(shaderProgram);

		if (!gl.getProgramParameterb(shaderProgram, WebGLRenderingContext.LINK_STATUS)) throw new RuntimeException("Could not initialise shaders");

		gl.useProgram(shaderProgram);
		
		vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "vertexPosition");
		gl.enableVertexAttribArray(vertexPositionAttribute);
		
		texCoordAttribute = gl.getAttribLocation(shaderProgram, "texPosition");
		gl.enableVertexAttribArray(texCoordAttribute);
		
		textureUniform = gl.getUniformLocation(shaderProgram, "tex");
		gl.uniform1i(textureUniform, 0);
		
		//checkErrors();
	}
	
	private WebGLShader getShader(int type, String source) {
		WebGLShader shader = gl.createShader(type);

		gl.shaderSource(shader, source);
		gl.compileShader(shader);

		if (!gl.getShaderParameterb(shader, WebGLRenderingContext.COMPILE_STATUS)) throw new RuntimeException(gl.getShaderInfoLog(shader));

		return shader;
	}
	
	private void initBuffers() {
		triangleVertexBuffer = gl.createBuffer();
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, triangleVertexBuffer);
		triangleVertices = Float32Array.create(3 * 3);
		gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, triangleVertices, WebGLRenderingContext.DYNAMIC_DRAW);
		
		rectVertexBuffer = gl.createBuffer();
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectVertexBuffer);
		rectVertices = Float32Array.create(bufferSize * 3 * 4);//6);
		gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, rectVertices, WebGLRenderingContext.DYNAMIC_DRAW);
		gl.vertexAttribPointer(vertexPositionAttribute, 3, WebGLRenderingContext.FLOAT, false, 0, 0);
		//rectVerticesCache = Float32Array.create(3 * 6);
		
		rectTexCoordBuffer = gl.createBuffer();
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectTexCoordBuffer);
		rectTexCoords = Float32Array.create(bufferSize * 2 * 4);//6);
		gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER, rectTexCoords, WebGLRenderingContext.DYNAMIC_DRAW);
		gl.vertexAttribPointer(texCoordAttribute, 2, WebGLRenderingContext.FLOAT, false, 0, 0);
		//rectTexCoordsCache = Float32Array.create(2 * 6);
		
		indexBuffer = gl.createBuffer();
		gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
		Uint16Array indices = Uint16Array.create(bufferSize * 3 * 2);
		
		for (int i = 0; i < bufferSize; ++i) {
			indices.set(i * 3 * 2 + 0, i * 4 + 0);
			indices.set(i * 3 * 2 + 1, i * 4 + 1);
			indices.set(i * 3 * 2 + 2, i * 4 + 2);
			indices.set(i * 3 * 2 + 3, i * 4 + 0);
			indices.set(i * 3 * 2 + 4, i * 4 + 2);
			indices.set(i * 3 * 2 + 5, i * 4 + 3);
		}
		
		gl.bufferData(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, indices, WebGLRenderingContext.STATIC_DRAW);
		
		gl.enableVertexAttribArray(vertexPositionAttribute);
		gl.enableVertexAttribArray(texCoordAttribute);
	}
	
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
	
	@SuppressWarnings("unused")
	private void checkErrors() {
		int error = gl.getError();
		if (error != WebGLRenderingContext.NO_ERROR) {
			String message = "WebGL Error: " + error;
			GWT.log(message, null);
			throw new RuntimeException(message);
		}
	}
	
	private void setRectVertices(float left, float top, float right, float bottom) {
		int baseIndex = bufferIndex * 3 * 4;
		rectVertices.set(baseIndex + 0, left  );
		rectVertices.set(baseIndex + 1, bottom   );
		rectVertices.set(baseIndex + 2, -5.0f);
		rectVertices.set(baseIndex + 3, left );
		rectVertices.set(baseIndex + 4, top   );
		rectVertices.set(baseIndex + 5, -5.0f );
		rectVertices.set(baseIndex + 6, right  );
		rectVertices.set(baseIndex + 7, top);
		rectVertices.set(baseIndex + 8, -5.0f );
		rectVertices.set(baseIndex + 9, right  );
		rectVertices.set(baseIndex +10, bottom);
		/*rectVertices.set(baseIndex +11, -5.0f );
		rectVertices.set(baseIndex +12, right );
		rectVertices.set(baseIndex +13, top   );
		rectVertices.set(baseIndex +14, -5.0f );
		rectVertices.set(baseIndex +15, right );
		rectVertices.set(baseIndex +16, bottom);*/
		
		//gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectVertexBuffer);
		//gl.bufferSubData(WebGLRenderingContext.ARRAY_BUFFER, bufferIndex * 3 * 6 * 4, rectVerticesCache);
	}
	
	private void setRectTexCoords(float left, float top, float right, float bottom) {
		int baseIndex = bufferIndex * 2 * 4;
		rectTexCoords.set(baseIndex + 0, left  );
		rectTexCoords.set(baseIndex + 1, bottom   );
		rectTexCoords.set(baseIndex + 2, left );
		rectTexCoords.set(baseIndex + 3, top   );
		rectTexCoords.set(baseIndex + 4, right  );
		rectTexCoords.set(baseIndex + 5, top);
		rectTexCoords.set(baseIndex + 6, right  );
		rectTexCoords.set(baseIndex + 7, bottom);
		/*rectTexCoords.set(baseIndex + 8, right );
		rectTexCoords.set(baseIndex + 9, top   );
		rectTexCoords.set(baseIndex +10, right );
		rectTexCoords.set(baseIndex +11, bottom);*/
		
		//gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectTexCoordBuffer);
		//gl.bufferSubData(WebGLRenderingContext.ARRAY_BUFFER, bufferIndex * 2 * 6 * 4, rectTexCoordsCache);
	}

	private void setTexture(WebImage img) {
		if (img.tex == null) {
			img.tex = gl.createTexture();
			gl.activeTexture(WebGLRenderingContext.TEXTURE0);
			gl.bindTexture(WebGLRenderingContext.TEXTURE_2D, img.tex);
			//glContext.pixelStorei(WebGLRenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
			gl.texParameteri(WebGLRenderingContext.TEXTURE_2D, WebGLRenderingContext.TEXTURE_MIN_FILTER, WebGLRenderingContext.NEAREST);
			gl.texParameteri(WebGLRenderingContext.TEXTURE_2D, WebGLRenderingContext.TEXTURE_MAG_FILTER, WebGLRenderingContext.NEAREST);
			gl.texParameteri(WebGLRenderingContext.TEXTURE_2D, WebGLRenderingContext.TEXTURE_WRAP_S, WebGLRenderingContext.CLAMP_TO_EDGE);
			gl.texParameteri(WebGLRenderingContext.TEXTURE_2D, WebGLRenderingContext.TEXTURE_WRAP_T, WebGLRenderingContext.CLAMP_TO_EDGE);
			gl.texImage2D(WebGLRenderingContext.TEXTURE_2D, 0, WebGLRenderingContext.RGBA, WebGLRenderingContext.RGBA, WebGLRenderingContext.UNSIGNED_BYTE, img.img.getElement());
			gl.uniform1i(textureUniform, 0);
		}
		else gl.bindTexture(WebGLRenderingContext.TEXTURE_2D, img.tex);
	}
	
	private void drawBuffer() {
		//java.lang.System.err.println("drawBuffer " + bufferIndex);
		setTexture((WebImage)lastTexture);
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectVertexBuffer);
		gl.bufferSubData(WebGLRenderingContext.ARRAY_BUFFER, 0, Float32Array.create(rectVertices.getBuffer(), 0, bufferIndex * 4 * 3));
		gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectTexCoordBuffer);
		gl.bufferSubData(WebGLRenderingContext.ARRAY_BUFFER, 0, Float32Array.create(rectTexCoords.getBuffer(), 0, bufferIndex * 4 * 2));
		gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
		
		gl.drawElements(WebGLRenderingContext.TRIANGLES, bufferIndex * 2 * 3, WebGLRenderingContext.UNSIGNED_SHORT, 0);
		//gl.drawArrays(WebGLRenderingContext.TRIANGLES, 0, bufferIndex * 6);
		
		bufferIndex = 0;
		//checkErrors();
	}
	
	@Override
	public void drawImage(Image img, double x, double y) {
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && img != lastTexture)) drawBuffer();
		
		float left = (float)(tx + x);
		float top = (float)(ty + y);
		float right = (float)(tx + x + img.getWidth());
		float bottom = (float)(ty + y + img.getHeight());
		
		setRectTexCoords(0, 0, 1, 1);
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = img;
	}
	
	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && img != lastTexture)) drawBuffer();
		
		float left = (float)(tx + dx);
		float top = (float)(ty + dy);
		float right = (float)(tx + dx + dw);
		float bottom = (float)(ty + dy + dh);
		
		setRectTexCoords((float)(sx / img.getWidth()), (float)(sy / img.getHeight()), (float)((sx + sw) / img.getWidth()), (float)((sy + sh) / img.getHeight()));
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = img;
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
		gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT);// | WebGLRenderingContext.DEPTH_BUFFER_BIT);
	}
	
	@Override
	public void end() {
		if (bufferIndex > 0) drawBuffer();
		lastTexture = null;
		gl.flush();
		//java.lang.System.err.println("frame end");
	}
}