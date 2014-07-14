package kha;

import kha.Painter;

class LoadingScreen extends Game {
	public function new() {
		super("Loading", false);
	}
	
	override public function render(frame: Framebuffer) {
		startRender(frame);
		if (Loader.the != null) {
			frame.g2.color = Color.fromBytes(0, 0, 255);
			frame.g2.fillRect(width / 4, height / 2 - 10, Loader.the.getLoadPercentage() * width / 2 / 100, 20);
			frame.g2.color = Color.Black;
			frame.g2.drawRect(width / 4, height / 2 - 10, width / 2, 20);
		}
		endRender(frame);
	}
	
	override public function update() {
		
	}
}
