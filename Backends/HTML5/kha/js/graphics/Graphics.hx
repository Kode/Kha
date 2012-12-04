package kha.js.graphics;

class Graphics implements kha.graphics.Graphics {
	public function new() {
		
	}
	
	public function createVertexBuffer(vertexCount: Int): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount);
	}
	
	public function createIndexBuffer(indexCount: Int): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function createTexture(image: kha.Image): kha.graphics.Texture {
		return new Texture(image);
	}
	
	public function drawIndexedVertices(start: Int = 0, ?count: Int): Void {
		
	}
	
	
}