package kha;

import kha.Painter;

class LoadingScreen extends Game {
	public function new() {
		super("Loading", false);
	}
	
	override public function render(painter: Painter) {
		if (Loader.the != null) {
			painter.setColor(0, 0, 255);
			painter.fillRect(width / 4, height / 2 - 10, Loader.the.getLoadPercentage() * width / 2 / 100, 20);
			painter.setColor(0, 0, 0);
			painter.drawRect(width / 4, height / 2 - 10, width / 2, 20);
		}
	}
	
	override public function update() {
		
	}
}