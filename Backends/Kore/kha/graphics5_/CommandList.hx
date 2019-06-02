package kha.graphics5;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics5/CommandList.h>
')

@:headerClassCode("Kore::Graphics5::CommandList* commandList;")
class CommandList {

	public function new() {
		init();
	}

	@:functionCode('commandList = new Kore::Graphics5::CommandList();')
	private function init(): Void {

	}

	public function begin(): Void {
		untyped __cpp__("commandList->begin();");
	}

	public function end(): Void {
		untyped __cpp__("commandList->end();");
	}

	public function renderTargetToFramebufferBarrier(renderTarget: RenderTarget): Void {
		untyped __cpp__("commandList->renderTargetToFramebufferBarrier(renderTarget->renderTarget);");
	}

	public function framebufferToRenderTargetBarrier(renderTarget: RenderTarget): Void {
		untyped __cpp__("commandList->framebufferToRenderTargetBarrier(renderTarget->renderTarget);");
	}

	public function setRenderTargets(targets:Array<RenderTarget>): Void {
		var len = targets.length;
		var image1 = targets[0];
		var image2 = targets[1];
		var image3 = targets[2];
		var image4 = targets[3];
		var image5 = targets[4];
		var image6 = targets[5];
		var image7 = targets[6];
		untyped __cpp__("Kore::Graphics5::RenderTarget* renderTargets[8] = { image1 == null() ? nullptr : image1->renderTarget, image2 == null() ? nullptr : image2->renderTarget, image3 == null() ? nullptr : image3->renderTarget, image4 == null() ? nullptr : image4->renderTarget, image5 == null() ? nullptr : image5->renderTarget, image6 == null() ? nullptr : image6->renderTarget, image7 == null() ? nullptr : image7->renderTarget }; commandList->setRenderTargets(renderTargets, len);");
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		untyped __cpp__("commandList->drawIndexedVertices();");
	}

	public function setIndexBuffer(indexBuffer: IndexBuffer): Void {
		untyped __cpp__("commandList->setIndexBuffer(*indexBuffer->buffer);");
	}

	public function setVertexBuffers(vertexBuffers: Array<VertexBuffer>, offsets: Array<Int>): Void {
		var vb = vertexBuffers[0];
		untyped __cpp__("int offs[1] = { 0 }; Kore::Graphics5::VertexBuffer* buffers[1] = { vb->buffer }; commandList->setVertexBuffers(buffers, offs, 1);");
	}

	public function setPipelineLayout(): Void {
		untyped __cpp__("commandList->setPipelineLayout();");
	}

	public function setPipeline(pipeline: PipelineState): Void {
		untyped __cpp__("commandList->setPipeline(pipeline->pipeline);");
	}

	public function clear(target:RenderTarget, ?color: Color, ?depth: Float, ?stencil: Int): Void {
		untyped __cpp__("commandList->clear(target->renderTarget, Kore::Graphics5::ClearColorFlag);");
	}

	public function upload(indexBuffer: IndexBuffer): Void {
		untyped __cpp__("commandList->upload(indexBuffer->buffer);");
	}
}
