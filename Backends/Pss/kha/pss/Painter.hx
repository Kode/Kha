package kha.pss;

import kha.Image;

@:classContents('
	private Sce.Pss.Core.Graphics.GraphicsContext graphics;
	private Sce.Pss.Core.Graphics.ShaderProgram shaderProgram;
	private Sce.Pss.Core.Graphics.VertexBuffer vertexBuffer;
')
class Painter extends kha.Painter {
	var tx : Float;
	var ty : Float;
	
	public function new() {
		tx = 0;
		ty = 0;
		initGraphics();
	}
	
	@:functionBody('
		graphics = new Sce.Pss.Core.Graphics.GraphicsContext();

		shaderProgram = new Sce.Pss.Core.Graphics.ShaderProgram("/Application/shaders/Texture.cgx");
		shaderProgram.SetUniformBinding(0, "WorldViewProj");
	
		float[] vertices = new float[12];
	
		vertices[0]=0.0f;   // x0
		vertices[1]=0.0f;   // y0
		vertices[2]=0.0f;   // z0
	
		vertices[3]=0.0f;   // x1
		vertices[4]=1.0f;   // y1
		vertices[5]=0.0f;   // z1
	
		vertices[6]=1.0f;   // x2
		vertices[7]=0.0f;   // y2
		vertices[8]=0.0f;   // z2
	
		vertices[9]=1.0f;   // x3
		vertices[10]=1.0f;  // y3
		vertices[11]=0.0f;  // z3
		
		float[] texcoords = new float[4 * 2];
		texcoords[0] = 0.0f;
		texcoords[1] = 0.0f;
		
		texcoords[2] = 0.0f;
		texcoords[3] = 1.0f;
		
		texcoords[4] = 1.0f;
		texcoords[5] = 0.0f;
		
		texcoords[6] = 1.0f;
		texcoords[7] = 1.0f;
		
		float[] colors = new float[4 * 4];
		for (int i = 0; i < 16; ++i) colors[i] = 1.0f;
		
		vertexBuffer = new Sce.Pss.Core.Graphics.VertexBuffer(4, 6, Sce.Pss.Core.Graphics.VertexFormat.Float3, Sce.Pss.Core.Graphics.VertexFormat.Float2, Sce.Pss.Core.Graphics.VertexFormat.Float4);

		vertexBuffer.SetVertices(0, vertices);
		vertexBuffer.SetVertices(1, texcoords);
		vertexBuffer.SetVertices(2, colors);
	
		ushort[] indices = new ushort[6];
		indices[0] = 0;
		indices[1] = 2;
		indices[2] = 1;
		indices[3] = 1;
		indices[4] = 2;
		indices[5] = 3;
		
		vertexBuffer.SetIndices(indices);
		graphics.SetVertexBuffer(0, vertexBuffer);
	')
	function initGraphics() : Void {
		
	}

	@:functionBody('
		graphics.SetClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		graphics.Clear();
	')
	override public function begin() : Void {
		
	}
	
	@:functionBody('
		graphics.SwapBuffers();
	')
	override public function end() : Void {
		
	}
	
	override public function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	@:functionBody('
		Sce.Pss.Core.Imaging.ImageRect rectScreen = graphics.Screen.Rectangle;
		Sce.Pss.Core.Graphics.Texture2D texture = ((kha.pss.Image)img).texture;
		int Width = texture.Width;
		int Height = texture.Height;
		var unitScreenMatrix = new Sce.Pss.Core.Matrix4(
			Width*2.0f/rectScreen.Width,   0.0f,       0.0f, 0.0f,
			0.0f,   Height*(-2.0f)/rectScreen.Height,  0.0f, 0.0f,
			0.0f,   0.0f, 1.0f, 0.0f,
			-1.0f,  1.0f, 0.0f, 1.0f
		);
		
		graphics.SetShaderProgram(shaderProgram);
		graphics.SetTexture(0, texture);
		shaderProgram.SetUniformValue(0, ref unitScreenMatrix);
	
		graphics.DrawArrays(Sce.Pss.Core.Graphics.DrawMode.Triangles, 0, 6);
	')
	override public function drawImage(img : Image, x : Float, y : Float) : Void {
	
	}
	
	override public function drawImage2(image : Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) : Void {
		
	}
}