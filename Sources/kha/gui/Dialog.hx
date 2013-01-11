package kha.gui;

import kha.Configuration;

class Dialog {
	public function new(titletext: String, texttext: String) {
		//backimage = new ImageItem(Skin::the()->deletewindow()));

		var x = Configuration.screen().width / 2 - backimage.width / 2;
		var y = Configuration.screen().height / 2 - backimage.height / 2;
		backimage.setPos(x, y);
		add(backimage);
		cursor = CursorStyle.Pointer;
	
		title = new TextItem(titletext);
		title.setColor(Color.fromBytes(0x62, 0x5b, 0x52));
		title.setFontSize(21);
		add(title);
	
		text = new TextItem(texttext);
		text.setColor(Color.fromBytes(0x62, 0x5b, 0x52));
		text.setFontSize(21);
		text.setPos(x + 30, y + 60);
		text.setTextWidth(backimage.width - 60);
		add(text);

		title.setPos(x + 30, y + 10);

		button1 = new Button("Abbrechen", 19, 130);
		button1.setPos(x + 20, y + 140);
		button1.pressed = function() { cancel(); };
		add(button1);

		button2 = new Button("Loeschen", 19, 105);
		button2.setPos(x + 172, y + 140);
		button2.pressed = function() { ok(); };
		add(button2);
	}
	
	public var ok: Void -> Void;
	
	public var cancel: Void -> Void;

	public var backimage: ImageItem;
	
	public var title: TextItem;
	
	public var text: TextItem;
	
	public var button1: Button;
	
	public var button2: Button;
	
	override private function getWidth(): Float {
		return Configuration.screen().width;
	}
	
	override private function getHeight(): Float {
		return Configuration.screen().height;
	}

	override public function mouseDown(event: MouseEvent): Item {
		return this;
	}
}