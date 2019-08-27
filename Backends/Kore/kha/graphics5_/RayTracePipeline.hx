package kha.graphics5;

#if kha_dxr

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics5/RayTrace.h>
')

@:headerClassCode("Kore::Graphics5::RayTracePipeline* pipeline;")
class RayTracePipeline {

	public function new(commandList: CommandList, rayTraceShader: kha.Blob, constantBuffer: ConstantBuffer) {
		untyped __cpp__("pipeline = new Kore::Graphics5::RayTracePipeline(commandList->commandList, rayTraceShader->bytes->b->Pointer(), rayTraceShader->get_length(), constantBuffer->buffer);");
	}

	@:keep
	function _forceInclude(): Void {
		haxe.io.Bytes.alloc(0);
	}
}

#end
