package kha.flash;

import kha.Cursor;
import kha.Image;

class Mouse extends kha.Mouse {
	public function new() {
		super();
	}
	
	override private function hideSystemCursor():Void {
		flash.ui.Mouse.hide();
	}
	override private function showSystemCursor():Void {
		flash.ui.Mouse.show();
	}
}
