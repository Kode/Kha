package kha.gui;
import kha.gui.MouseEvent;
import kha.gui.Item;
import kha.Painter;

class TextEdit extends Item {
	public function new() {
		
	}
	
	public var text: String = "";
	
	override public function render(painter: Painter): Void {
		painter.setColor(255, 255, 255);
		painter.fillRect(0, 0, width, height);
		painter.setColor(0, 0, 0);
		painter.drawString(text, 10, 20);
	}
	
	override public function mouseDown(event: MouseEvent): Item {
		var cursor = new TextCursor();
		cursor.editor = this;
		return this;
	}

	public function append(value: String): Void {
		text = text + value;
	}
}