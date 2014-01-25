package kha;

class Mouse {
	private var hidden: Bool = false;
	private var cursors: Array<Cursor>;
	private var cursorIndex: Int;
	
	public function new() {
		cursors = new Array<Cursor>();
		cursorIndex = -1;
	}
	
	public function show(): Void {
		hidden = false;
	}
	
	public function hide(): Void {
		hidden = true;
	}
	
	public function pushCursor(cursorImage: Cursor): Void {
		++cursorIndex;
		cursors[cursorIndex] = cursorImage;
	}
	
	public function popCursor(): Void {
		--cursorIndex;
		if (cursorIndex < -1) cursorIndex = -1;
	}
	
	public function render(painter: Painter, x: Int, y: Int): Void {
		if (cursorIndex >= 0) cursors[cursorIndex].render(painter, x, y);
	}
	
	public function update(x: Int, y: Int): Void {
		if (cursorIndex >= 0) cursors[cursorIndex].update(x, y);
	}
}
