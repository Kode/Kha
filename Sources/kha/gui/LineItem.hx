package kha.gui;

import kha.Color;
import kha.Painter;

class LineItem extends Item {
	public function new(x1: Float = 0, y1: Float = 0, x2: Float = 100, y2: Float = 100) {
		setLine(x1, y1, x2, y2);
	}
	
	public var col: Color;
	
	public var x1: Float;
	
	public var y1: Float;
	
	public var x2: Float;
	
	public var y2: Float;

	override private function getWidth(): Float {
		return Math.abs(x2 - x1);
	}
	
	override private function getHeight(): Float {
		return Math.abs(y2 - y1);
	}
	
	override public function render(painter: Painter): Void {
		painter.drawLine(x1, y1, x2, y2);
	}
	
	public function setLine(x1: Float, y1: Float, x2: Float, y2: Float): Void {
		this.x1 = x1;
		this.y1 = y1;
		this.x2 = x2;
		this.y2 = y2;
	}
}