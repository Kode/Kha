package kha.flash;

import kha.Image;

class Mouse extends kha.Mouse {
	public function new() {
		super();
	}
	
	override public function show(): Void {
		super.show();
		if (cursorIndex < 0) flash.ui.Mouse.show();
	}
	
	override public function hide(): Void {
		super.hide();
		if (cursorIndex < 0) flash.ui.Mouse.hide();
	}
	
	override public function pushCursor(cursorImage: Image): Void {
		super.pushCursor(cursorImage);
		flash.ui.Mouse.hide();
	}
	
	override public function popCursor(): Void {
		super.popCursor();
		if (cursorIndex < 0) {
			if (hidden) flash.ui.Mouse.hide();
			else flash.ui.Mouse.show();
		}
	}
}
