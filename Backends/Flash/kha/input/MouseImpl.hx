package kha.input;

class MouseImpl extends Mouse {
	public function new() {
		super();
	}
	
	public override function hideSystemCursor(): Void {
		flash.ui.Mouse.hide();
	}
	
	public override function showSystemCursor(): Void {
		flash.ui.Mouse.show();
	}
}
