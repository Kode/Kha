package kha.js;

import js.Browser;
import js.html.CanvasElement;
import kha.Cursor;
import kha.Image;

class Mouse extends kha.Mouse {
	var khanvas : CanvasElement;
	public static var SystemCursor : String = "default";
	
	// TODO (FM): I added this function for actually changing the cursor when using hyperlink-buttons in HTML5 - Maybe this is not the best way to do it?
	public static function UpdateSystemCursor() {
		var khanvas2 = cast Browser.document.getElementById("khanvas");
		khanvas2.style.cursor = SystemCursor;
	}
	
	public function new() {
		super();
		khanvas = cast Browser.document.getElementById("khanvas");
		khanvas.style.cursor = SystemCursor;
	}
	
	override private function hideSystemCursor():Void {
		khanvas.style.cursor = "none";
	}
	override private function showSystemCursor():Void {
		khanvas.style.cursor = SystemCursor;
	}
}
