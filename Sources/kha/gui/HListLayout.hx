package kha.gui;

class HListLayout extends Item {
	public function new() {
		myHeight = 100;
		items = new Array<Item>();
	}
	
	public var items: Array<Item>;
	
	public static var spacing = 5;
	
	public function addWidget(item: Item): Void {
		add(item);
		items.push(item);
		positionItems();
	}

	public function positionItems(): Void {
		myWidth = 0;
		myHeight = 0;

		for (item in items) {
			if (item.height > myHeight) myHeight = item.height;
			item.setPos(myWidth, 0);
			myWidth += item.width + spacing;
		}
		myWidth -= spacing;
	}

	public function removeWidget(item: Item): Void {
		for (it in items) {
			if (it == item) {
				items.remove(it);
				break;
			}
		}
		positionItems();
	}

	public function getItem(index: Int): Item {
		return items[index];
	}

	public function count(): Int {
		return items.length;
	}
}