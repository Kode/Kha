package kha.graphics5;

#if kha_dxr

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics5/RayTrace.h>
')

@:headerClassCode("Kore::Graphics5::AccelerationStructure* accel;")
class AccelerationStructure {

	public function new(commandList: CommandList, vb: VertexBuffer, ib: IndexBuffer) {
		init(commandList, vb, ib);
	}

	function init(commandList: CommandList, vb: VertexBuffer, ib: IndexBuffer) {
		untyped __cpp__("accel = new Kore::Graphics5::AccelerationStructure(commandList->commandList, vb->buffer, ib->buffer);");
	}
}

#end
