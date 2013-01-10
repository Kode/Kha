package kha.gui;

class Tabs extends Item {
	public function new() {
		super();
		width = 700;
		height = 500;
		tabs = new Array<Tab>();
	}
	
	public var tabs: Array<Tab>;
	
	public var tabcount = 0;
	
	public function createTab(name: String): Tab {
		var tab = new Tab();
		tab.tabs = this;
		tab.position = tabcount;
		tab.text = name;
		children.push(tab);
		tabs.push(tab);
		++tabcount;
		return tab;
	}

	public function activate(num: Int): Void {
		var tab = tabs[num];
		children.remove(tab);
		for (i in 0...tabs.length) tabs[i].active = false;
		children.push(tab);
		tab.active = true;
	}
}