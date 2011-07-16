package com.kontechs.kje.backends.gwt;

import com.google.gwt.canvas.client.Canvas;
import com.google.gwt.canvas.dom.client.Context2d;
import com.google.gwt.canvas.dom.client.CssColor;
import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.user.client.ui.FocusPanel;
import com.googlecode.gwtgl.array.Float32Array;
import com.googlecode.gwtgl.array.TypedArray;
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
	private WebGLRenderingContext glContext;
    private WebGLProgram shaderProgram;
    private int vertexPositionAttribute;
    private WebGLBuffer vertexBuffer;

    private Canvas canvas;
	private Context2d context;
	private double tx, ty;
	
	public CanvasPainter(FocusPanel panel, int width, int height) {
		final WebGLCanvas webGLCanvas = new WebGLCanvas(width + "px", height + "px");
        glContext = webGLCanvas.getGlContext();
        glContext.viewport(0, 0, width, height);
        panel.add(webGLCanvas);
		
        initShaders();
        glContext.clearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glContext.clearDepth(1.0f);
        glContext.enable(WebGLRenderingContext.DEPTH_TEST);
        glContext.depthFunc(WebGLRenderingContext.LEQUAL);
        initBuffers();
        
        drawScene();
        
		/*canvas = Canvas.createIfSupported();
		canvas.setWidth(width + "px");
		canvas.setHeight(height + "px");
		canvas.setCoordinateSpaceWidth(width);
		canvas.setCoordinateSpaceHeight(height);
		context = canvas.getContext2d();
		
		panel.add(canvas);*/
	}
	
	private void initShaders() {
        WebGLShader fragmentShader = getShader(WebGLRenderingContext.FRAGMENT_SHADER, "void main(void)\n{\ngl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);\n}");
        WebGLShader vertexShader = getShader(WebGLRenderingContext.VERTEX_SHADER, "attribute vec3 vertexPosition;\nuniform mat4 perspectiveMatrix;\nvoid main(void)\n{\ngl_Position = perspectiveMatrix * vec4(vertexPosition, 1.0);\n}");

        shaderProgram = glContext.createProgram();
        glContext.attachShader(shaderProgram, vertexShader);
        glContext.attachShader(shaderProgram, fragmentShader);
        glContext.linkProgram(shaderProgram);

        if (!glContext.getProgramParameterb(shaderProgram, WebGLRenderingContext.LINK_STATUS)) {
                throw new RuntimeException("Could not initialise shaders");
        }

        glContext.useProgram(shaderProgram);

        vertexPositionAttribute = glContext.getAttribLocation(shaderProgram, "vertexPosition");
        glContext.enableVertexAttribArray(vertexPositionAttribute);
	}
	
	private WebGLShader getShader(int type, String source) {
        WebGLShader shader = glContext.createShader(type);

        glContext.shaderSource(shader, source);
        glContext.compileShader(shader);

        if (!glContext.getShaderParameterb(shader, WebGLRenderingContext.COMPILE_STATUS)) {
                throw new RuntimeException(glContext.getShaderInfoLog(shader));
        }

        return shader;
	}
	
	private void initBuffers() {
		vertexBuffer = glContext.createBuffer();
		glContext.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, vertexBuffer);
		float[] vertices = new float[]{
				0.0f,  1.0f,  -5.0f, // first vertex
				-1.0f, -1.0f,  -5.0f, // second vertex
				1.0f, -1.0f,  -5.0f  // third vertex
		};
		glContext.bufferData(WebGLRenderingContext.ARRAY_BUFFER, Float32Array.create(vertices), WebGLRenderingContext.STATIC_DRAW);
	}
	
	private float[] createPerspectiveMatrix(int fieldOfViewVertical, float aspectRatio, float minimumClearance, float maximumClearance) {
        float top    = minimumClearance * (float)Math.tan(fieldOfViewVertical * Math.PI / 360.0);
        float bottom = -top;
        float left   = bottom * aspectRatio;
        float right  = top * aspectRatio;

        float X = 2*minimumClearance/(right-left);
        float Y = 2*minimumClearance/(top-bottom);
        float A = (right+left)/(right-left);
        float B = (top+bottom)/(top-bottom);
        float C = -(maximumClearance+minimumClearance)/(maximumClearance-minimumClearance);
        float D = -2*maximumClearance*minimumClearance/(maximumClearance-minimumClearance);

        return new float[]{     X, 0.0f, A, 0.0f,
                                                0.0f, Y, B, 0.0f,
                                                0.0f, 0.0f, C, -1.0f,
                                                0.0f, 0.0f, D, 0.0f};
	}
	
	void drawScene() {
		glContext.clear(WebGLRenderingContext.COLOR_BUFFER_BIT | WebGLRenderingContext.DEPTH_BUFFER_BIT);
        float[] perspectiveMatrix = createPerspectiveMatrix(45, 1, 0.1f, 1000);
        WebGLUniformLocation uniformLocation = glContext.getUniformLocation(shaderProgram, "perspectiveMatrix");
        glContext.uniformMatrix4fv(uniformLocation, false, perspectiveMatrix);
        glContext.vertexAttribPointer(vertexPositionAttribute, 3, WebGLRenderingContext.FLOAT, false, 0, 0);
        glContext.drawArrays(WebGLRenderingContext.TRIANGLES, 0, 3);
	}
	
	@Override
	public void drawImage(Image img, double x, double y) {
		//context.drawImage(((WebImage)img).getIE(), tx + x, ty + y);
	}
	
	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
		//context.drawImage(((WebImage)img).getIE(), sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
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
}