package kha.psm;

import kha.Image;
import kha.Rotation;

/*@:classCode('
	public static Sce.PlayStation.Core.Graphics.GraphicsContext graphics;
	private Sce.PlayStation.Core.Graphics.ShaderProgram shaderProgram;
	private Sce.PlayStation.Core.Graphics.VertexBuffer vertexBuffer;
	private float[] vertices;
	private float[] texcoords;
')*/
class Painter { //extends kha.Painter {
	/*var tx: Float;
	var ty: Float;
	
	public function new() {
		super();
		tx = 0;
		ty = 0;
		initGraphics();
	}
	
	@:functionCode('
		graphics = new Sce.PlayStation.Core.Graphics.GraphicsContext();
		shaderProgram = new Sce.PlayStation.Core.Graphics.ShaderProgram("/Application/shaders/Texture.cgx");
		shaderProgram.SetUniformBinding(0, "WorldViewProj");

		vertices = new float[12];
		texcoords = new float[4 * 2];
		float[] colors = new float[4 * 4];
		for (int i = 0; i < 16; ++i) colors[i] = 1.0f;

		vertexBuffer = new Sce.PlayStation.Core.Graphics.VertexBuffer(4, 6, Sce.PlayStation.Core.Graphics.VertexFormat.Float3, Sce.PlayStation.Core.Graphics.VertexFormat.Float2, Sce.PlayStation.Core.Graphics.VertexFormat.Float4);

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
		graphics.SetShaderProgram(shaderProgram);
		
		Sce.PlayStation.Core.Imaging.ImageRect rectScreen = graphics.Screen.Rectangle;
		
		float right = rectScreen.Width;
		float left = 0;
		float top = 0;
		float bottom = rectScreen.Height;
		float zNear = 0.1f;
		float zFar = 512.0f;
	
		float tx = -(right + left) / (right - left);
		float ty = -(top + bottom) / (top - bottom);
		float tz = -zNear / (zFar - zNear);
		
		var unitScreenMatrix = new Sce.PlayStation.Core.Matrix4(
			2.0f / (right - left), 0.0f,                  0.0f,                  0.0f,
			0.0f,                  2.0f / (top - bottom), 0.0f,                  0.0f,
			0.0f,                  0.0f,                  1.0f / (zFar - zNear), 0.0f,
			tx,                    ty,                    tz,                    1.0f
		);	
	
		shaderProgram.SetUniformValue(0, ref unitScreenMatrix);
		
		graphics.SetBlendFunc(Sce.PlayStation.Core.Graphics.BlendFuncMode.Add,Sce.PlayStation.Core.Graphics.BlendFuncFactor.SrcAlpha, Sce.PlayStation.Core.Graphics.BlendFuncFactor.OneMinusSrcAlpha);
	')
	function initGraphics(): Void {
		
	}

	@:functionCode('
		graphics.SetClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		graphics.Clear();
	')
	override public function begin(): Void {
		
	}
	
	@:functionCode('
		graphics.SwapBuffers();
	')
	override public function end(): Void {
		
	}
	
	override public function translate(x: Float, y: Float) {
		tx = x;
		ty = y;
	}
	
	override public function drawImage(img: Image, x: Float, y: Float): Void {
		drawImage2(img, 0, 0, img.width, img.height, x, y, img.width, img.height);
	}
	
	@:functionCode('
		Sce.PlayStation.Core.Graphics.Texture2D texture = ((kha.psm.Image)image).texture;
		int Width = texture.Width;
		int Height = texture.Height;
			
		graphics.SetTexture(0, texture);
		
		vertices[0] = (float)(tx + dx);
		vertices[1] = (float)(ty + dy);
		vertices[2] = 0.0f;   // z0

		vertices[3] = (float)(tx + dx);   // x1
		vertices[4] = (float)(ty + dy + dh);   // y1
		vertices[5] = 0.0f;   // z1

		vertices[6] = (float)(tx + dx + dw);   // x2
		vertices[7] = (float)(ty + dy);   // y2
		vertices[8] = 0.0f;   // z2

		vertices[9]  = (float)(tx + dx + dw);   // x3
		vertices[10] = (float)(ty + dy + dh);  // y3
		vertices[11] = 0.0f;  // z3
		
		texcoords[0] = (float)(sx / Width);
		texcoords[1] = (float)(sy / Height);
		
		texcoords[2] = (float)(sx / Width);
		texcoords[3] = (float)((sy + sh) / Height);
		
		texcoords[4] = (float)((sx + sw) / Width);
		texcoords[5] = (float)(sy / Height);
		
		texcoords[6] = (float)((sx + sw) / Width);
		texcoords[7] = (float)((sy + sh) / Height);
		
		vertexBuffer.SetVertices(0, vertices);
		vertexBuffer.SetVertices(1, texcoords);
	
		graphics.DrawArrays(Sce.PlayStation.Core.Graphics.DrawMode.Triangles, 0, 6);
	')
	override public function drawImage2(image: Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float, rotation: Rotation = null): Void {
		
	}*/
}
