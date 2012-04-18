package kha;

import kha.Painter;

class LoadingScreen extends Game {
	public function new(width : Int, height : Int) {
		super("Loading", width, height, false);
	}
	
	override public function render(painter : Painter) {
		if (Loader.getInstance() != null) {
			painter.setColor(0, 0, 255);
			painter.fillRect(width / 4, height / 2 - 10, Loader.getInstance().getLoadPercentage() * width / 2 / 100, 20);
			painter.setColor(0, 0, 0);
			painter.drawRect(width / 4, height / 2 - 10, width / 2, 20);
		}
	}
	
	override public function update() {
		
	}
}