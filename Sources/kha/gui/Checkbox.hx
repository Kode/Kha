package kha.gui;

import kha.gui.MouseEvent;
import kha.gui.Item;
import kha.Image;

class Checkbox extends ImageItem {
	public function new() {
		//onpic = Skin::the()->checkboxchecked();
		//offpic = Skin::the()->checkbox();
		setImage(offpic);
	}
	
	public var toggled: Void -> Void;
	
	public var on(default, setChecked): Bool = false;
	
	public var onpic: Image;
	
	public var offpic: Image;

	override public function mouseDown(event: MouseEvent): Item {
		on = !on;
		updatePixmap();
		toggled(on);
	}
	
	private function setChecked(checked: Bool): Bool {
		on = checked;
		updatePixmap();
		return on;
	}

	private function updatePixmap(): Void {
		if (on) setImage(onpic);
		else setImage(offpic);
	}
}