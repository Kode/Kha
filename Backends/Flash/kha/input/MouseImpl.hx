package kha.input;

class MouseImpl extends Mouse {
	private static var mouse: MouseImpl;
	
	public static function init(): Void {
		mouse = new MouseImpl();
	}
	
	public static function get(num: Int): Mouse {
		if (num != 0) return null;
		return mouse;
	}
	
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
