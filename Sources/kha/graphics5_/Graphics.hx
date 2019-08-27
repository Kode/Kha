package kha.graphics5;

interface Graphics {
	function begin(target: RenderTarget): Void;
	function end(): Void;
	function swapBuffers(): Void;
	#if kha_dxr
	function setAccelerationStructure(accel: AccelerationStructure): Void;
	function setRayTracePipeline(pipe: RayTracePipeline): Void;
	function setRayTraceTarget(target: RayTraceTarget): Void;
	function dispatchRays(commandList: CommandList): Void;
	function copyRayTraceTarget(commandList: CommandList, renderTarget: RenderTarget, output: RayTraceTarget): Void;
	#end
}
