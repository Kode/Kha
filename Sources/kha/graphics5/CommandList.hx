package kha.graphics5;

interface CommandList {
	function setVertexBuffer(vertexBuffer: VertexBuffer): Void;
	function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void;
	function setIndexBuffer(indexBuffer: IndexBuffer): Void;

	function uploadIndexBuffer(buffer: IndexBuffer): Void;
	function uploadVertexBuffer(buffer: VertexBuffer): Void;
	function uploadTexture(texture: Image): Void;

	function setTexture(unit: TextureUnit, texture: Image): Void;
	function setTextureDepth(unit: TextureUnit, texture: Image): Void;
	function setTextureArray(unit: TextureUnit, texture: Image): Void;
	function setVideoTexture(unit: TextureUnit, texture: Video): Void;
	function setImageTexture(unit: TextureUnit, texture: Image): Void;
	function setTextureParameters(texunit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void;
	function setTexture3DParameters(texunit: TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, wAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void;
	function setCubeMap(unit: TextureUnit, cubeMap: CubeMap): Void;
	function setCubeMapDepth(unit: TextureUnit, cubeMap: CubeMap): Void;
	
	function setPipeline(pipeline: PipelineState): Void;
	
	function setVertexConstants(buffer: ConstantBuffer): Void;
	function setFragmentConstants(buffer: ConstantBuffer): Void;

	function drawIndexedVertices(start: Int = 0, count: Int = -1): Void;
	function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void;

	function renderTargetToFramebufferBarrier(renderTarget: Image): Void;
	function framebufferToRenderTargetBarrier(renderTarget: Image): Void;
	function textureToRenderTargetBarrier(renderTarget: Image): Void;
	function renderTargetToTextureBarrier(renderTarget: Image): Void;

	function execute(): Void;
	function executeAndWait(): Void;
}
