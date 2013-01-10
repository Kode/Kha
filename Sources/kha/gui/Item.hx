package kha.gui;

import kha.Painter;

class Item {
	public function new() {
		children = new Array<Item>();
	}
	
	public var children: Array<Item>;
	
	public var x: Int = 0;
	
	public var y: Int = 0;
	
	public var width: Int = 100;
	
	public var height: Int = 100;
	
	public var clipping = false;
	
	public var visible = true;
	
	public function mouseDown(event: MouseEvent): Item {
		var mouseX = event.x;
		var mouseY = event.y;
		Layer.xtrans -= x;
		Layer.ytrans -= y;
		event.translate( -x, -y);
		var i = children.length - 1;
		while (i >= 0) {
			var item = children[i];
			var itemX = item.x;
			var itemY = item.y;
			if (mouseX >= itemX + x && mouseX <= itemX + x + item.width && mouseY >= itemY + y && mouseY <= itemY + y + item.height) {
				var pressed = item.mouseDown(event);
				if (pressed != null) return pressed;
			}
			--i;
		}
		event.translate(x, y);
		Layer.xtrans += x;
		Layer.ytrans += y;
		return null;
	}
	
	public function mouseUp  (event: MouseEvent): Void { }
	
	public function mouseMove(event: MouseEvent): Void {
		var mouseX = event.x;
		var mouseY = event.y;
		event.translate( -x, -y);
		var i = children.length - 1;
		while (i >= 0) {
			var item = children[i];
			var itemX = item.x;
			var itemY = item.y;
			if (mouseX >= itemX + x && mouseX <= itemX + x + item.width && mouseY >= itemY + y && mouseY <= itemY + y + item.height) {
				item.mouseMove(event);
			}
			--i;
		}
		event.translate(x, y);
	}
	
	public function render(painter: Painter): Void {
		
	}
}