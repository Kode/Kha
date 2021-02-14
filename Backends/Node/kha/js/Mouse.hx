package kha.js;

import js.Browser;
import js.html.CanvasElement;
import kha.Cursor;
import kha.Image;

class Mouse extends kha.Mouse {
	public static var SystemCursor: String = "default";

	public static function UpdateSystemCursor() {}

	public function new() {
		super();
	}

	override function hideSystemCursor(): Void {}

	override function showSystemCursor(): Void {}

	override public function update(): Void {}
}
