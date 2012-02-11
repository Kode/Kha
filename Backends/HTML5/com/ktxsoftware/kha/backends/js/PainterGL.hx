package com.ktxsoftware.kha.backends.js;
import com.ktxsoftware.kha.Font;
import js.Lib;

class PainterGL extends com.ktxsoftware.kha.Painter {
	var gl : Dynamic;
    var shaderProgram : Dynamic;
    var vertexPositionAttribute : Int;
	var texCoordAttribute : Int;
    var triangleVertexBuffer : Dynamic;
	var rectVertexBuffer : Dynamic;
	var rectTexCoordBuffer : Dynamic;
    var triangleVertices : Dynamic;
    var rectVertices : Dynamic;
	var rectTexCoords : Dynamic;//, rectVerticesCache, rectTexCoordsCache;
	var textureUniform : Dynamic;
	var indexBuffer : Dynamic;
	static var bufferSize : Int = 100;
	var bufferIndex : Int;
	var lastTexture : Image;
	var tx : Float;
	var ty : Float;
	
	public function new(gl : Dynamic, width : Int, height : Int) {
		this.gl = gl;
		gl.viewport(0, 0, width, height);
		
		initShaders();
		gl.clearColor(1.0, 1.0, 1.0, 1.0);
		gl.clearDepth(1.0);
		//glContext.enable(WebGLRenderingContext.DEPTH_TEST);
		//glContext.enable(WebGLRenderingContext.TEXTURE_2D);
		//glContext.depthFunc(WebGLRenderingContext.LEQUAL);
		gl.enable(gl.BLEND);
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
		initBuffers();

		var projectionMatrix : Array<Float> = ortho(0, width, height, 0, 0.1, 1000);
		var uniformLocation : Dynamic = gl.getUniformLocation(shaderProgram, "projectionMatrix");
		gl.uniformMatrix4fv(uniformLocation, false, projectionMatrix);
		
		//checkErrors();
	}
	
	function initShaders() : Void {
		var fragmentShader : Dynamic = getShader(gl.FRAGMENT_SHADER,
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
		
		var vertexShader : Dynamic = getShader(gl.VERTEX_SHADER,
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

		//if (!gl.getProgramParameterb(shaderProgram, WebGLRenderingContext.LINK_STATUS)) throw Exception("Could not initialise shaders");

		gl.useProgram(shaderProgram);
		
		vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "vertexPosition");
		gl.enableVertexAttribArray(vertexPositionAttribute);
		
		texCoordAttribute = gl.getAttribLocation(shaderProgram, "texPosition");
		gl.enableVertexAttribArray(texCoordAttribute);
		
		textureUniform = gl.getUniformLocation(shaderProgram, "tex");
		gl.uniform1i(textureUniform, 0);
		
		//checkErrors();
	}
	
	function getShader(type : Int, source : String) : Dynamic {
		var shader : Dynamic = gl.createShader(type);

		gl.shaderSource(shader, source);
		gl.compileShader(shader);

		//if (!gl.getShaderParameterb(shader, WebGLRenderingContext.COMPILE_STATUS)) throw new RuntimeException(gl.getShaderInfoLog(shader));

		return shader;
	}
	
	function initBuffers() : Void {
		triangleVertexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexBuffer);
		triangleVertices = untyped __js__('new Float32Array(3 * 3)');
		gl.bufferData(gl.ARRAY_BUFFER, triangleVertices, gl.DYNAMIC_DRAW);
		
		rectVertexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, rectVertexBuffer);
		rectVertices = untyped __js__('new Float32Array(com.ktxsoftware.kha.backends.js.PainterGL.bufferSize * 3 * 4)');//6);
		gl.bufferData(gl.ARRAY_BUFFER, rectVertices, gl.DYNAMIC_DRAW);
		gl.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0);
		//rectVerticesCache = Float32Array.create(3 * 6);
		
		rectTexCoordBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, rectTexCoordBuffer);
		rectTexCoords = untyped __js__('new Float32Array(com.ktxsoftware.kha.backends.js.PainterGL.bufferSize * 2 * 4)');//6);
		gl.bufferData(gl.ARRAY_BUFFER, rectTexCoords, gl.DYNAMIC_DRAW);
		gl.vertexAttribPointer(texCoordAttribute, 2, gl.FLOAT, false, 0, 0);
		//rectTexCoordsCache = Float32Array.create(2 * 6);
		
		indexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		var indices = untyped __js__('new Uint16Array(com.ktxsoftware.kha.backends.js.PainterGL.bufferSize * 3 * 2)');
		
		for (i in 0...bufferSize) {
			indices[i * 3 * 2 + 0] = i * 4 + 0;
			indices[i * 3 * 2 + 1] = i * 4 + 1;
			indices[i * 3 * 2 + 2] = i * 4 + 2;
			indices[i * 3 * 2 + 3] = i * 4 + 0;
			indices[i * 3 * 2 + 4] = i * 4 + 2;
			indices[i * 3 * 2 + 5] = i * 4 + 3;
		}
		
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
		
		gl.enableVertexAttribArray(vertexPositionAttribute);
		gl.enableVertexAttribArray(texCoordAttribute);
	}
	
	function ortho(left : Float, right : Float, bottom : Float, top : Float, zn : Float, zf : Float) : Array<Float> {
		var tx : Float = -(right + left) / (right - left);
		var ty : Float = -(top + bottom) / (top - bottom);
		var tz : Float = -(zf + zn) / (zf - zn);
		return [
			2 / (right - left), 0,                  0,              0,
			0,                  2 / (top - bottom), 0,              0,
			0,                  0,                  -2 / (zf - zn), 0,
			tx,                 ty,                 tz,             1
		];
	}
	
	function checkErrors() : Void {
		var error : Int = gl.getError();
		if (error != gl.NO_ERROR) {
			var message : String = "WebGL Error: " + error;
			//GWT.log(message, null);
			//throw new RuntimeException(message);
		}
	}
	
	function setRectVertices(left : Float, top : Float, right : Float, bottom : Float) : Void {
		var baseIndex : Int = bufferIndex * 3 * 4;
		rectVertices[baseIndex + 0] = left;
		rectVertices[baseIndex + 1] = bottom;
		rectVertices[baseIndex + 2] = -5.0;
		rectVertices[baseIndex + 3] = left;
		rectVertices[baseIndex + 4] = top;
		rectVertices[baseIndex + 5] = -5.0;
		rectVertices[baseIndex + 6] = right;
		rectVertices[baseIndex + 7] = top;
		rectVertices[baseIndex + 8] = -5.0;
		rectVertices[baseIndex + 9] = right;
		rectVertices[baseIndex +10] = bottom;
		/*rectVertices.set(baseIndex +11, -5.0f );
		rectVertices.set(baseIndex +12, right );
		rectVertices.set(baseIndex +13, top   );
		rectVertices.set(baseIndex +14, -5.0f );
		rectVertices.set(baseIndex +15, right );
		rectVertices.set(baseIndex +16, bottom);*/
		
		//gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectVertexBuffer);
		//gl.bufferSubData(WebGLRenderingContext.ARRAY_BUFFER, bufferIndex * 3 * 6 * 4, rectVerticesCache);
	}
	
	function setRectTexCoords(left : Float, top : Float, right : Float, bottom : Float) : Void {
		var baseIndex : Int = bufferIndex * 2 * 4;
		rectTexCoords[baseIndex + 0] = left;
		rectTexCoords[baseIndex + 1] = bottom;
		rectTexCoords[baseIndex + 2] = left;
		rectTexCoords[baseIndex + 3] = top;
		rectTexCoords[baseIndex + 4] = right;
		rectTexCoords[baseIndex + 5] = top;
		rectTexCoords[baseIndex + 6] = right;
		rectTexCoords[baseIndex + 7] = bottom;
		/*rectTexCoords.set(baseIndex + 8, right );
		rectTexCoords.set(baseIndex + 9, top   );
		rectTexCoords.set(baseIndex +10, right );
		rectTexCoords.set(baseIndex +11, bottom);*/
		
		//gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, rectTexCoordBuffer);
		//gl.bufferSubData(WebGLRenderingContext.ARRAY_BUFFER, bufferIndex * 2 * 6 * 4, rectTexCoordsCache);
	}

	function setTexture(img : Image) : Void {
		if (img.tex == null) {
			img.tex = gl.createTexture();
			gl.activeTexture(gl.TEXTURE0);
			gl.bindTexture(gl.TEXTURE_2D, img.tex);
			//glContext.pixelStorei(WebGLRenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img.image);
			gl.uniform1i(textureUniform, 0);
		}
		else gl.bindTexture(gl.TEXTURE_2D, img.tex);
	}
	
	function drawBuffer() : Void {
		//java.lang.System.err.println("drawBuffer " + bufferIndex);
		setTexture(lastTexture);
		gl.bindBuffer(gl.ARRAY_BUFFER, rectVertexBuffer);
		gl.bufferSubData(gl.ARRAY_BUFFER, 0, untyped __js__('new Float32Array(this.rectVertices, 0, this.bufferIndex * 4 * 3)'));
		gl.bindBuffer(gl.ARRAY_BUFFER, rectTexCoordBuffer);
		gl.bufferSubData(gl.ARRAY_BUFFER, 0, untyped __js__('new Float32Array(this.rectTexCoords, 0, this.bufferIndex * 4 * 2)'));
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		
		gl.drawElements(gl.TRIANGLES, bufferIndex * 2 * 3, gl.UNSIGNED_SHORT, 0);
		//gl.drawArrays(gl.TRIANGLES, 0, bufferIndex * 6);
		
		bufferIndex = 0;
		//checkErrors();
	}
	
	public override function drawImage(img : com.ktxsoftware.kha.Image, x : Float, y : Float) : Void {
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && img != lastTexture)) drawBuffer();
		
		var left : Float = tx + x;
		var top : Float = ty + y;
		var right : Float = tx + x + img.getWidth();
		var bottom : Float = ty + y + img.getHeight();
		
		setRectTexCoords(0, 0, 1, 1);
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = cast(img, Image);
	}
	
	public override function drawImage2(img : com.ktxsoftware.kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) : Void {
		if (bufferIndex + 1 >= bufferSize || (lastTexture != null && img != lastTexture)) drawBuffer();
		
		var left : Float = tx + dx;
		var top : Float = ty + dy;
		var right : Float = tx + dx + dw;
		var bottom : Float = ty + dy + dh;
		
		setRectTexCoords(sx / img.getWidth(), sy / img.getHeight(), (sx + sw) / img.getWidth(), (sy + sh) / img.getHeight());
		setRectVertices(left, top, right, bottom);
		++bufferIndex;
		lastTexture = cast(img, Image);
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
		gl.clear(gl.COLOR_BUFFER_BIT);// | WebGLRenderingContext.DEPTH_BUFFER_BIT);
	}
	
	public override function end() : Void {
		if (bufferIndex > 0) drawBuffer();
		lastTexture = null;
		gl.flush();
		//java.lang.System.err.println("frame end");
	}
}