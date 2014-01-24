package kha;

class Mouse {
	private var hidden: Bool = false;
	private var cursorImages: Array<Image>;
	private var cursorIndex: Int;
	
	public function new() {
		cursorImages = new Array<Image>();
		cursorIndex = -1;
	}
	
	public function show(): Void {
		hidden = false;
	}
	
	public function hide(): Void {
		hidden = true;
	}
	
	public function pushCursor(cursorImage: Image): Void {
		++cursorIndex;
		cursorImages[cursorIndex] = cursorImage;
	}
	
	public function popCursor(): Void {
		--cursorIndex;
		if (cursorIndex < -1) cursorIndex = -1;
	}
	
	public function render(painter: Painter, x: Int, y: Int): Void {
		if (cursorIndex >= 0) painter.drawImage(cursorImages[cursorIndex], x, y);
	}
}
