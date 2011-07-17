package com.kontechs.kje.backends.gwt;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.LoadEvent;
import com.google.gwt.event.dom.client.LoadHandler;
import com.google.gwt.event.shared.HandlerRegistration;
import com.google.gwt.resources.client.ImageResource;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.RootPanel;
import com.googlecode.gwtgl.array.Float32Array;
import com.googlecode.gwtgl.binding.WebGLBuffer;
import com.googlecode.gwtgl.binding.WebGLCanvas;
import com.googlecode.gwtgl.binding.WebGLProgram;
import com.googlecode.gwtgl.binding.WebGLRenderingContext;
import com.googlecode.gwtgl.binding.WebGLShader;
import com.googlecode.gwtgl.binding.WebGLUniformLocation;
import com.kontechs.kje.Font;
import com.kontechs.kje.Image;
import com.kontechs.kje.Painter;

public class CanvasPainter implements Painter {
	private int width, height;
	
	private WebGLRenderingContext glContext;
    private WebGLProgram shaderProgram;
    private int vertexPositionAttribute, texCoordAttribute;
    private WebGLBuffer triangleVertexBuffer, rectVertexBuffer, rectTexCoordBuffer;
    private Float32Array triangleVertices;
    private Float32Array rectVertices, rectTexCoords;
	private WebGLUniformLocation textureUniform;

    //private Canvas canvas;
	//private Context2d context;
	private double tx, ty;
	
	public CanvasPainter(FocusPanel panel, int width, int height) {
		this.width = width;
		this.height = height;
		
		final WebGLCanvas webGLCanvas = new WebGLCanvas(width + "px", height + "px");
		glContext = webGLCanvas.getGlContext();
		glContext.viewport(0, 0, width, height);
		panel.add(webGLCanvas);
		
		initShaders();
		glContext.clearColor(0.0f, 0.0f, 0.0f, 1.0f);
		glContext.clearDepth(1.0f);
		//glContext.enable(WebGLRenderingContext.DEPTH_TEST);
		//glContext.enable(WebGLRenderingContext.TEXTURE_2D);
		//glContext.depthFunc(WebGLRenderingContext.LEQUAL);
		initBuffers();
		setImage(Resources.INSTANCE.texture());
checkErrors();
		//drawScene();

		/*canvas = Canvas.createIfSupported();
		canvas.setWidth(width + "px");
		canvas.setHeight(height + "px");
		canvas.setCoordinateSpaceWidth(width);
		canvas.setCoordinateSpaceHeight(height);
		context = canvas.getContext2d();
		
		panel.add(canvas);*/
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
				//+ "gl_FragColor = texture2D(tex, texCoord);"
		        + "gl_FragColor = texture2D(tex, vec2(0.5, 0.5));"
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
	
		shaderProgram = glContext.createProgram();
		glContext.attachShader(shaderProgram, vertexShader);
		glContext.attachShader(shaderProgram, fragmentShader);
		
		glContext.bindAttribLocation(shaderProgram, 0, "vertexPosition");
		glContext.bindAttribLocation(shaderProgram, 1, "texPosition");

		glContext.linkProgram(shaderProgram);

		if (!glContext.getProgramParameterb(shaderProgram, WebGLRenderingContext.LINK_STATUS)) throw new RuntimeException("Could not initialise shaders");

		glContext.useProgram(shaderProgram);
		
		vertexPositionAttribute = glContext.getAttribLocation(shaderProgram, "vertexPosition");
		glContext.enableVertexAttribArray(vertexPositionAttribute);
		
		texCoordAttribute = glContext.getAttribLocation(shaderProgram, "texPosition");
		glContext.enableVertexAttribArray(texCoordAttribute);
		
		textureUniform = glContext.getUniformLocation(shaderProgram, "tex");
		glContext.uniform1i(textureUniform, 0);
		
		checkErrors();
	}
	
	private WebGLShader getShader(int type, String source) {
		WebGLShader shader = glContext.createShader(type);

		glContext.shaderSource(shader, source);
		glContext.compileShader(shader);

		if (!glContext.getShaderParameterb(shader, WebGLRenderingContext.COMPILE_STATUS)) throw new RuntimeException(glContext.getShaderInfoLog(shader));

		return shader;
	}
	
	private void initBuffers() {
		triangleVertexBuffer = glContext.createBuffer();
		glContext.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, triangleVertexBuffer);
		float[] vertices = new float[]{
				200.0f,  300.0f,  -5.0f,
				100.0f, 100.0f,  -5.0f,
				300.0f, 100.0f,  -5.0f
		};
		triangleVertices = Float32Array.create(vertices);
		glContext.bufferData(WebGLRenderingContext.ARRAY_BUFFER, triangleVertices, WebGLRenderingContext.STATIC_DRAW);
		
		rectVertexBuffer = glContext.createBuffer();
		glContext.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectVertexBuffer);
		vertices = new float[]{
				100.0f, 100.0f,  -5.0f,
				300.0f, 100.0f,  -5.0f,
				100.0f, 300.0f,  -5.0f,
				300.0f, 300.0f,  -5.0f
		};
		rectVertices = Float32Array.create(vertices);
		glContext.bufferData(WebGLRenderingContext.ARRAY_BUFFER, rectVertices, WebGLRenderingContext.STATIC_DRAW);
		
		rectTexCoordBuffer = glContext.createBuffer();
		glContext.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectTexCoordBuffer);
		vertices = new float[]{
				0.0f, 0.0f,
				1.0f, 0.0f,
				0.0f, 1.0f,
				1.0f, 1.0f,
		};
		rectTexCoords = Float32Array.create(vertices);
		glContext.bufferData(WebGLRenderingContext.ARRAY_BUFFER, rectTexCoords, WebGLRenderingContext.STATIC_DRAW);
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
	
	private void checkErrors() {
		int error = glContext.getError();
		if (error != WebGLRenderingContext.NO_ERROR) {
			String message = "WebGL Error: " + error;
			GWT.log(message, null);
			throw new RuntimeException(message);
		}
	}
	
	private void setRectVertices(float left, float top, float right, float bottom) {
		rectVertices.set( 0, left);
		rectVertices.set( 1, top);
		rectVertices.set( 3, right);
		rectVertices.set( 4, top);
		rectVertices.set( 6, left);
		rectVertices.set( 7, bottom);
		rectVertices.set( 9, right);
		rectVertices.set(10, bottom);
		
		glContext.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectVertexBuffer);
		glContext.bufferSubData(WebGLRenderingContext.ARRAY_BUFFER, 0, rectVertices);
	}
	private HandlerRegistration handlerRegistration;
	com.google.gwt.user.client.ui.Image imageToSet;
	public void setImage(final ImageResource imageResource) {
       // if (destroyed) {
       //         throw new IllegalStateException(
       //                         "The Texture2D is already destroyed");
       // }

        final com.google.gwt.user.client.ui.Image img = new com.google.gwt.user.client.ui.Image();
        handlerRegistration = img.addLoadHandler(
        		new LoadHandler() {
                @Override
                public void onLoad(LoadEvent event) {
                        imageToSet=img;

                        RootPanel.get().remove(img);

                        if (handlerRegistration != null) {
                                handlerRegistration.removeHandler();
                                handlerRegistration = null;
                        }
                }
        });
        img.setVisible(false);
        RootPanel.get().add(img);
        // image.setResource(imageResource);
        // TODO doesn't work with more than one image bundled to one
        // ImageBundle if the browser doesn't support data:... urls
        // So it's no problem at the moment because Chrome and FF support it
        img.setUrl(imageResource.getURL());
	}
	
	private void setTexture(WebImage img) {
		if (img.tex == null) {
			if (imageToSet != null) {
				img.tex = glContext.createTexture();
				glContext.activeTexture(WebGLRenderingContext.TEXTURE0);
				glContext.bindTexture(WebGLRenderingContext.TEXTURE_2D, img.tex);
				glContext.pixelStorei(WebGLRenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
				glContext.texImage2D(WebGLRenderingContext.TEXTURE_2D, 0, WebGLRenderingContext.RGBA, WebGLRenderingContext.RGBA, WebGLRenderingContext.UNSIGNED_BYTE, imageToSet.getElement());//img.img.getElement());
				glContext.uniform1i(textureUniform, 0);
				checkErrors();
			}
		}
		else {
			glContext.activeTexture(WebGLRenderingContext.TEXTURE0);
			glContext.bindTexture(WebGLRenderingContext.TEXTURE_2D, img.tex);
			glContext.uniform1i(textureUniform, 0);
			checkErrors();
		}
	}
	
	@Override
	public void drawImage(Image img, double x, double y) {
		//context.drawImage(((WebImage)img).getIE(), tx + x, ty + y);
		
		float left = (float)(tx + x);
		float top = (float)(ty + y);
		float right = (float)(tx + x + img.getWidth());
		float bottom = (float)(ty + y + img.getHeight());
		
		setRectVertices(left, top, right, bottom);
		
		glContext.vertexAttribPointer(vertexPositionAttribute, 3, WebGLRenderingContext.FLOAT, false, 0, 0);
		glContext.vertexAttribPointer(texCoordAttribute, 2, WebGLRenderingContext.FLOAT, false, 0, 0);
		setTexture((WebImage)img);
		glContext.drawArrays(WebGLRenderingContext.TRIANGLE_STRIP, 0, 4);
	}
	
	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
		//context.drawImage(((WebImage)img).getIE(), sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
		
		if (dw == 32) return;
		
		float left = (float)(tx + dx);
		float top = (float)(ty + dy);
		float right = (float)(tx + dx + img.getWidth());
		float bottom = (float)(ty + dy + img.getHeight());
		
		setRectVertices(left, top, right, bottom);
		glContext.enableVertexAttribArray(vertexPositionAttribute);
		glContext.enableVertexAttribArray(texCoordAttribute);
		glContext.vertexAttribPointer(vertexPositionAttribute, 3, WebGLRenderingContext.FLOAT, false, 0, 0);
		glContext.vertexAttribPointer(texCoordAttribute, 2, WebGLRenderingContext.FLOAT, false, 0, 0);
		setTexture((WebImage)img);
		glContext.drawArrays(WebGLRenderingContext.TRIANGLE_STRIP, 0, 4);
		
		checkErrors();
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
		glContext.clear(WebGLRenderingContext.COLOR_BUFFER_BIT | WebGLRenderingContext.DEPTH_BUFFER_BIT);
		float[] projectionMatrix = ortho(0, width, height, 0, 0.1f, 1000);
		WebGLUniformLocation uniformLocation = glContext.getUniformLocation(shaderProgram, "projectionMatrix");
		glContext.uniformMatrix4fv(uniformLocation, false, projectionMatrix);
		//glContext.vertexAttribPointer(vertexPositionAttribute, 3, WebGLRenderingContext.FLOAT, false, 0, 0);
		//glContext.drawArrays(WebGLRenderingContext.TRIANGLE_STRIP, 0, 4);
	}
	
	@Override
	public void end() {
		glContext.flush();
	}
}