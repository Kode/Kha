package kha.gui;
import kha.Painter;

class Layer {
	public static var xtrans: Float = 0;
	public static var ytrans: Float = 0;
	public var objects: Array<Item>;
	private var pressed: Item = null;
	
	public function new() {
		objects = new Array<Item>();
	}
	
	public function mouseDown(event: MouseEvent): Void {
		xtrans = 0;
		ytrans = 0;
		var x = event.x;
		var y = event.y;
		var i = objects.length - 1;
		while (i >= 0) {
			var item = objects[i];
			if (x >= item.x && x <= item.x + item.width && y >= item.y && y <= item.y + item.height) {
				var pressed = item.mouseDown(event);
				if (pressed != null) {
					this.pressed = pressed;
					break;
				}
			}
			--i;
		}
	}
	
	public function mouseUp(event: MouseEvent): Void {
		if (pressed != null) {
			event.translate(xtrans, ytrans);
			pressed.mouseUp(event);
			pressed = null;
		}
	}
	
	public function mouseMove(event: MouseEvent): Void {
		if (pressed != null) {
			event.translate(xtrans, ytrans);
			pressed.mouseMove(event);
		}
		else {
			var x = event.x;
			var y = event.y;
			var i = objects.length - 1;
			while (i >= 0) {
				var item = objects[i];
				if (x >= item.x && x <= item.x + item.width && y >= item.y && y <= item.y + item.height) {
					item.mouseMove(event);
				}
				--i;
			}
		}
	}
	
	private function renderItem(painter: Painter, item: Item): Void {
		item.render(painter);
		painter.translate(-item.x, -item.y);
		for (child in item.children) {
			renderItem(painter, child);
		}
		painter.translate(item.x, item.y);
	}
	
	public function render(painter: Painter): Void {
		for (object in objects) {
			renderItem(painter, object);
		}
	}
}