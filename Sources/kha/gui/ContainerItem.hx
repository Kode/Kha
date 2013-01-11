package kha.gui;

class ContainerItem extends Item {
	public function new() {
		
	}
	
	override private function getWidth(): Float {
		var max: Float = 0;
		for (item in items) {
			if (item.x + item.width > max) max = item.x + item.width;
		}
		return max;
	}
	
	override private function getHeight(): Float {
		var max: Float = 0;
		for (item in items) {
			if (item.y + item.height > max) max = item.y + item.height;
		}
		return max;
	}
}