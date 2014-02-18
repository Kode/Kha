package kha.js;

import js.Browser;
import js.html.CanvasElement;
import kha.Cursor;
import kha.Image;

class Mouse extends kha.Mouse {
	var khanvas : CanvasElement;
	public static var SystemCursor : String = "default";
	
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
