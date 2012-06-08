package kha.pss;

import kha.Image;

@:classContents('
	private static Sce.Pss.Core.Graphics.GraphicsContext graphics;
')
class Painter extends kha.Painter {
	var tx : Float;
	var ty : Float;
	
	public function new() {
		tx = 0;
		ty = 0;
		initGraphics();
	}
	
	@:functionBody('
		graphics = new Sce.Pss.Core.Graphics.GraphicsContext();
	')
	function initGraphics() : Void {
		
	}

	@:functionBody('
		graphics.SetClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		graphics.Clear();
	')
	override public function begin() : Void {
		
	}
	
	@:functionBody('
		graphics.SwapBuffers();
	')
	override public function end() : Void {
		
	}
	
	override public function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	override public function drawImage(img : Image, x : Float, y : Float) : Void {
	
	}
	
	override public function drawImage2(image : Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) : Void {
		
	}
}