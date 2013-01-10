package kha.gui;

class ScrollContent extends Item {
	public function new() {
		width = 0;
		height = 0;
	}
	
	public function add(item: Item): Void {
		{
			var xmax = x + item.width;
			if (xmax > width) width = xmax;
		}
		{
			var ymax = y + value.height;
			if (ymax > height) height = ymax;
		}
		children.push(item);
	}
}