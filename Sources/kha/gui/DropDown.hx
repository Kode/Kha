package kha.gui;
import kha.gui.MouseEvent;

import kha.gui.Item;
import kha.Painter;

class DropDownCatcher extends Item {
	public function new() {
		
	}
	
	public var dropDown: DropDown = null;
	
	public var ddx = 0;
	
	public var ddy = 0;
	
	override public function render(painter: Painter): Void {
		var size = dropDown.items.length;
		painter.setColor(102, 102, 102);
		painter.fillRect(ddx, ddy, dropDown.width, size * 25);
		painter.setColor(177, 177, 177);
		for (i in 0...size) {
			painter.drawString(dropDown.items[i], ddx, ddy + i * 25);
		}
	}
	
	override public function mouseDown(event: MouseEvent): Item {
		var x = event.x;
		var y = event.y;
		var size = dropDown.items.length;
		if (x > ddx && x < ddx + dropDown.width && y > ddy && y < ddy + size * 25.0f) {
			var index = Std.int((y - ddy) / 25);
			dropDown.selected = index;
		}
		//layer()("objects")("remove:", self);
		return this;
	}
}

class DropDown extends Item {
	public function new() {
		width = 75;
		selected = 0;
		items = new Array<String>();
	}
	
	public var selected = 0;
	
	public var items: Array<String>;
	
	public function add(text: String): Void {
		items.push(text);
	}

	override public function render(painter: Painter): Void {
		String text = items[selected];
		painter.drawString(text, 5, 5);
	}

	override public function mouseDown(event: MouseEvent): Item {
		var catcher = new DropDownCatcher();
		catcher.width = Configuration.screen().width;
		catcher.height = Configuration.screen().height;
		catcher.dropDown = this;
		catcher.ddx = event.globalX - event.x + x;
		catcher.ddy = event.globalY - event.y + y;
		//layer()("objects")("add:", catcher);
		return this;
	}
}