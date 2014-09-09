package kha.gui;
import kha.graphics2.Graphics;

class Item {
	public function new() {
		cursor = CursorStyle.Ignore;
		children = new Array<Item>();
	}
	
	public var children: Array<Item>;
	
	public var x: Float = 0;
	
	public var y: Float = 0;
	
	public var width(get, set): Float;
	
	public var height(get, set): Float;
	
	public var clipping = false;
	
	public var visible = true;
	
	private var myWidth: Float = 100;
	private var myHeight: Float = 100;
	
	private function get_width(): Float {
		return myWidth;
	}
	
	private function set_width(value: Float): Float {
		myWidth = value;
		return myWidth;
	}
	
	private function get_height(): Float {
		return myHeight;
	}
	
	private function set_height(value: Float): Float {
		myHeight = value;
		return myHeight;
	}
	
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
	
	public function mouseEnter(): Void {
		
	}
	
	public function mouseLeave(): Void {
		
	}
	
	public function render(g: Graphics): Void {
		
	}
	
	public var parent: Item;

	public var hover: Bool = false;
	
	public var moveable: Bool = false;

	public var cursor: CursorStyle;
	
	public function add(item: Item): Void {
		if (contains(item)) return;
		item.parent = this;
		children.push(item);
	}

	public function remove(item: Item): Void {
		item.parent = null;
		children.remove(item);
	}
	
	public function contains(item: Item): Bool {
		for (child in children) {
			if (child == item) return true;
		}
		return false;
	}
	
	public function setPos(x: Float, y: Float): Void {
		this.x = x;
		this.y = y;
	}

	public function centerX(): Void {
		x = parent.width / 2 - width / 2;
	}
	
	public function centerY(): Void {
		y = parent.height / 2 - height / 2;
	}
	
	public function center(): Void {
		centerX();
		centerY();
	}
}
