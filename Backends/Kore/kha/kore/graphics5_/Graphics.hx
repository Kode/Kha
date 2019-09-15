package kha.kore.graphics5;

import kha.graphics5.RenderTarget;
import kha.graphics5.CommandList;
#if kha_dxr
import kha.graphics5.AccelerationStructure;
import kha.graphics5.RayTraceTarget;
import kha.graphics5.RayTracePipeline;
#end

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics5/Graphics.h>
#include <Kore/Graphics5/RayTrace.h>
')

class Graphics implements kha.graphics5.Graphics {

	private var target: Canvas;
	
	public function new(target: Canvas = null) {
		this.target = target;
	}

	public function begin(target: RenderTarget): Void {
		untyped __cpp__("Kore::Graphics5::begin(target->renderTarget);");
	}
	
	public function end(): Void {
		untyped __cpp__("Kore::Graphics5::end();");
	}

	public function swapBuffers(): Void {
		untyped __cpp__("Kore::Graphics5::swapBuffers();");
	}

	#if kha_dxr
	public function setAccelerationStructure(accel: AccelerationStructure): Void {
		untyped __cpp__("Kore::Graphics5::setAccelerationStructure(accel->accel);");
	}

	public function setRayTracePipeline(pipe: RayTracePipeline): Void {
		untyped __cpp__("Kore::Graphics5::setRayTracePipeline(pipe->pipeline);");
	}

	public function setRayTraceTarget(target: RayTraceTarget): Void {
		untyped __cpp__("Kore::Graphics5::setRayTraceTarget(target->target);");
	}

	public function dispatchRays(commandList: CommandList): Void {
		untyped __cpp__("Kore::Graphics5::dispatchRays(commandList->commandList);");
	}

	public function copyRayTraceTarget(commandList: CommandList, renderTarget: RenderTarget, output: RayTraceTarget): Void {
		untyped __cpp__("Kore::Graphics5::copyRayTraceTarget(commandList->commandList, renderTarget->renderTarget, output->target);");
	}
	#end
}
