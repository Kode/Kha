package kha.gui;

import kha.Color;
import kha.Painter;

class RectItem extends Item {
	public function new(x: Float = 0, y: Float = 0, width: Float = 100, height: Float = 100) {
		color = new Color(255, 0, 0);
		setRect(x, y, width, height);
	}
	
	public var color: Color;
	
	public function setRect(x: Float, y: Float, width: Float, height: Float): Void {
		setPos(x, y);
		this.width = width;
		this.height = height;
	}
	
	override public function render(painter: Painter): Void {
		painter.setColor(color.r, color.g, color.b);
		painter.fillRect(0, 0, width, height);
	}
}