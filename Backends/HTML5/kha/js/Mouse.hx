package kha.js;

import js.Browser;
import js.html.CanvasElement;
import kha.Cursor;
import kha.Image;

class Mouse extends kha.Mouse {
	public static var SystemCursor : String = "default";
	
	// TODO (FM): I added this function for actually changing the cursor when using hyperlink-buttons in HTML5 - Maybe this is not the best way to do it?
	public static function UpdateSystemCursor() {
		Sys.khanvas.style.cursor = SystemCursor;
	}
	
	public function new() {
		super();
		Sys.khanvas.style.cursor = SystemCursor;
	}
	
	override private function hideSystemCursor():Void {
		Sys.khanvas.style.cursor = "none";
	}
	override private function showSystemCursor():Void {
		Sys.khanvas.style.cursor = SystemCursor;
	}
}
