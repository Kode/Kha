package kha.gui;
import kha.gui.MouseEvent;
import kha.gui.Item;
import kha.Painter;

class Tab extends Item {
	public function new() {
		super();
		width = 320;
		height = 426 + tabTopHeight;
		
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
	
	public var text: String = "";
	
	private var tabTopWidth = 70;
	private var tabTopHeight = 30;

	public function tabTopPosition(position: Int): Int {
		return 5 + position * (tabTopWidth + 2);
	}

	override public function add(item: Item): Void {
		content.children.push(item);
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
		}
		else {
			painter.setColor(25, 25, 25);
		}
		painter.fillRect(0, tabTopHeight, width, height - tabTopHeight);
		painter.fillRect(tabTopPosition(position), 0, tabTopWidth, tabTopHeight);
		painter.setColor(255, 255, 255);
		painter.drawString(text, tabTopPosition(position) + 5, 5);
	}
}