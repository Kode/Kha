package kha.gui;
import kha.Painter;

class TextCursor extends Item {
	public function new() {
		width = 1;
		height = 20;
	}
	
	public var editor: TextEdit = null;
	
	override public function render(painter: Painter): Void {
		painter.setColor(0, 0, 0);
		painter.fillRect(0, 0, width, height);
	}
	
	/*
	void keyDown(KeyEvent* event) {
		Obj cursor = gui()("TextCursor");
		if (cursor("editor") == Object::Nil()) return;
		if (event->isChar()) {
			cursor("editor")("append:", Text(event->tochar()));
		}
	}

	void keyUp(KeyEvent* event) {

	}
	*/
}