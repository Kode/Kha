package kha.gui;

import kha.Color;
import kha.Painter;

class Rect extends Item {
	public function new() {
		color = new Color(255, 0, 0);
	}
	
	public var color: Color;
	
	override public function render(painter: Painter): Void {
		painter.setColor(color.r, color.g, color.b);
		painter.fillRect(0, 0, width, height);
	}
}