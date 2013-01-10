package kha.gui;

class Tabs extends Item {
	public function new() {
		width = 700;
		height = 500;
		tabs = new Array<Tab>();
	}
	
	public var tabs: Array<Tab>;
	
	public var tabcount = 0;
	
	public function createTab(): Tab {
		var tab = new Tab();
		tab.tabs = this;
		tab.position = tabcount;
		tab.text = "Tab";
		children.push(tab);
		tabs.push(tab);
		++tabcount;
		return tab;
	}

	public function activate(num: Int): Void {
		var tab = tabs[num];
		children.remove(tab);
		var size = children.length;
		for (i in 0...size) children[i].active = false;
		children.push(tab);
		tab.active = true;
	}
}