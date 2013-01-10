package kha.gui;

import kha.Painter;

class ScrollBar extends Item {
	public function new() {
		x = 380;
		width = 20;
		height = 400;
		handle = new ScrollBarHandle();
		children.push(handle);
	}
	
	public var handle: ScrollBarHandle;
	
	public var area: Scroller;

	override public function render(painter: Painter): Void {
		painter.setColor(38, 38, 38);
		painter.fillRect(0, 0, width, height);
	}

	public function arrange(): Void {
		x = area.width - 20;
		handle.arrange();
	}
}