package sce.playstation.core.graphics;

@:native("Sce.PlayStation.Core.Graphics.GraphicsContext")
extern class GraphicsContext {
	public function new();
	public function DrawArrays(mode: DrawMode, first: Int, count: Int): Void;
	public function SetTexture(index: Int, texture: Texture2D): Void;
	public function SetVertexBuffer(index: Int, buffer: VertexBuffer): Void;
	public function SetShaderProgram(program: ShaderProgram): Void;
	public function SetBlendFunc(mode: BlendFuncMode, srcFactor: BlendFuncFactor, dstFactor: BlendFuncFactor): Void;
	public function Enable(mode: EnableMode, status: Bool): Void;
	public function SwapBuffers(): Void;
}
