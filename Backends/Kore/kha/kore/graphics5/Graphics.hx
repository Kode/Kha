package kha.kore.graphics5;

import kha.graphics5.RenderTarget;

class Graphics implements kha.graphics5.Graphics {

	private var target: Canvas;
	
	public function new(target: Canvas = null) {
		this.target = target;
	}

	@:functionCode('return Kore::Graphics5::renderTargetsInvertedY();')
	public function renderTargetsInvertedY(): Bool {
		return false;
	}

	public function begin(target:RenderTarget): Void {
		
	}
	
	public function end(): Void {
		
	}

	public function swapBuffers(): Void {
		
	}
}
