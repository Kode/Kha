package kha;

class Mouse {
	private var hidden: Bool = false;
	private var forceSystem: Bool = false;
	private var cursors: Array<Cursor>;
	private var cursorIndex: Int;
	
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
		throw "Not implemented";
	}
	
	private function showSystemCursor(): Void {
		throw "Not implemented";
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
	
	public function render(painter: Painter, x: Int, y: Int): Void {
		if (cursorIndex >= 0 && !hidden) cursors[cursorIndex].render(painter, x, y);
	}
	
	public function update(x : Int, y : Int): Void {
		if (cursorIndex >= 0) cursors[cursorIndex].update(x,y);
	}
}
