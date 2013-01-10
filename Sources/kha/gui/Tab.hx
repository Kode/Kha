package kha.gui;
import kha.gui.MouseEvent;
import kha.gui.Item;
import kha.Painter;

class Tab extends Item {
	public function new() {
		width = 700;
		height = 500;
		
		content = new Item();
		content.y = tabTopHeight;
		content.width = width;
		content.height = height - tabTopHeight;
		clipping = true;
		children.push(content);
	}
	
	public var content: Item;
	
	public var active = false;
	
	public var position = 0;
	
	public var tabs: Tabs;
	
	private var tabTopWidth = 100;
	private var tabTopHeight = 30;

	public function tabTopPosition(position: Int): Int {
		return 5 + position * (tabTopWidth + 2);
	}

	public function add(item: Item): Void {
		content.children.add(item);
	}

	override public function mouseDown(event: MouseEvent): Item {
		if (active) {
			return super.mouseDown(event);
		}
		if (event.y < tabTopHeight) {
			if (event.x > tabTopPosition(position) && event.x < tabTopPosition(position) + tabTopWidth) {
				if (!active) tabs.activate(position);
				return this;
			}
			else return null;
		}
		else return this;
	}
	
	override public function render(painter: Painter): Void {
		if (active) {
			painter.setColor(51, 51, 51);
			painter("color").assign("red", 0.2f);
			painter("color").assign("green", 0.2f);
			painter("color").assign("blue", 0.2f);
		}
		else {
			painter.setColor(25, 25, 25);
		}
		painter.fillRect(0, tabTopHeight, width, height - tabTopHeight);
		painter.fillRect(tabTopPosition(position), 0, tabTopWidth, tabTopHeight);
	}
}