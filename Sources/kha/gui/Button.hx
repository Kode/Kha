package kha.gui;

import kha.Painter;
import kha.gui.Item;
import kha.gui.MouseEvent;

class Button extends Item {
	public function new(text: String) {
		super();
		width = 300;
		height = 25;
		this.text = text;
	}
	
	public var text: String;
	
	public function pressed(): Void {
		
	}
	
	override public function render(painter: Painter): Void {
		painter.setColor(77, 77, 77);
		painter.fillRect(0, 0, width, height);
		painter.setColor(177, 177, 177);
		painter.drawString(text, 5, 5);
	}

	override public function mouseDown(event: MouseEvent): Item {
		return this;
	}
	
	override public function mouseUp(event: MouseEvent): Void {
		pressed();
	}
}