package kha;

class Mouse {
	private var hidden: Bool = false;
	private var forceSystem: Bool = false;
	private var cursors: Array<Cursor>;
	private var cursorIndex: Int;
	
	@:extern public var x(get, never) : Int;
	@:extern public var y(get, never) : Int;
	
	@:access(kha.Starter) @:extern inline function get_x() : Int { return kha.Starter.mouseX; /* implement if error (Don't forget to call mouse render) */ }
	@:access(kha.Starter) @:extern inline function get_y() : Int { return kha.Starter.mouseY; /* implement if error (Don't forget to call mouse render) */ }
	
	public function new() {
		cursors = new Array<Cursor>();
		cursorIndex = -1;
	}
	
	public function show(): Void {
		hidden = false;
		if (cursorIndex < 0 || forceSystem) showSystemCursor();
	}
	
	public function hide(): Void {
		hidden = true;
		hideSystemCursor();
	}
	
	private function hideSystemCursor(): Void {
		//throw "Not implemented";
	}
	
	private function showSystemCursor(): Void {
		//throw "Not implemented";
	}
	
	public function forceSystemCursor(force : Bool) : Void {
		forceSystem = force;
		if (forceSystem) {
			if (!hidden) showSystemCursor();
		} else if (cursorIndex >= 0) {
			hideSystemCursor();
		}
	}
	
	public function pushCursor(cursorImage: Cursor): Void {
		++cursorIndex;
		cursors[cursorIndex] = cursorImage;
		if (!forceSystem) hideSystemCursor();
	}
	
	public function popCursor(): Void {
		--cursorIndex;
		if (cursorIndex <= -1) {
			cursorIndex = -1;
			if (!hidden) {
				showSystemCursor();
			}
		}
	}
	
	public function render(g: kha.graphics2.Graphics): Void {
		if (cursorIndex >= 0 && !hidden) cursors[cursorIndex].render(g, x, y);
	}
	
	public function update(): Void {
		if (cursorIndex >= 0) cursors[cursorIndex].update(x, y);
	}
}
