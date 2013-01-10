package kha.gui;
import kha.gui.MouseEvent;
import kha.gui.Item;
import kha.Painter;

class ScrollBarHandle extends Item {
	public function new() {
		width = 20;
		height = 40;
	}
	
	public var dragged = false;

	public var yoffset = 0;
	
	public var area: Scroller;
	
	override public function render(painter: Painter): Void {
		painter.setColor(64, 64, 64);
		painter.fillRect(0, 0, width, height);
	}

	override public function mouseDown(event: MouseEvent): Item {
		dragged = true;
		yoffset = event.y - y;
		return this;
	}
	
	override public function mouseMove(event: MouseEvent): Void {
		if (dragged) {
			var ypos = event.y - yoffset;
			var handleHeight = height;
			var barHeight = area.bar.height;
			ypos = Math.max(0, ypos);
			ypos = Math.min(ypos, barHeight - handleHeight);
			y = ypos;
			var yrel = ypos / (barHeight - handleHeight);
			var contentHeight = area.content.height - barHeight;
			area.moveTo(-yrel * contentHeight);
		}
	}

	override public function mouseUp(event: MouseEvent): Void {
		dragged = false;
	}

	public function arrange(): Void {
		var contentHeight = area.content.height;
		var barHeight = area.bar.height;
		var handleHeight = barHeight * (barHeight / contentHeight);
		height = handleHeight;
	}
}