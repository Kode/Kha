package kha.gui;
import kha.Painter;

class Scroller extends Item {
	public function new() {
		width = 400;
		height = 400;
		clipping = true;
		content = new ScrollContent();
		bar = new ScrollBar();
		children.push(content);
		children.push(bar);
		bar.area = this;
		bar.handle.area = this;
	}
	
	public var transx = 0;
	
	public var transy = 0;
	
	public var content: ScrollContent;
	
	public var bar: ScrollBar;
	
	override public function render(painter: Painter): Void {
		painter.setColor(51, 51, 51);
		painter.fillRect(0, 0, width, height);
	}

	public function add(item: Item): Void {
		content.add(item);
	}
	
	public function moveTo(y: Int): Void {
		content.y = y;
	}
	
	public function arrange(): Void {
		bar.arrange();
	}
}