package kha.kore.graphics5;

import kha.graphics5.RenderTarget;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics5/Graphics.h>
')

class Graphics implements kha.graphics5.Graphics {

	private var target: Canvas;
	
	public function new(target: Canvas = null) {
		this.target = target;
	}

	public function renderTargetsInvertedY(): Bool {
		return untyped __cpp__("Kore::Graphics5::renderTargetsInvertedY();");
	}

	public function begin(target:RenderTarget): Void {
		untyped __cpp__("Kore::Graphics5::begin(target->renderTarget);");
	}
	
	public function end(): Void {
		untyped __cpp__("Kore::Graphics5::end();");
	}

	public function swapBuffers(): Void {
		untyped __cpp__("Kore::Graphics5::swapBuffers();");
	}
}
