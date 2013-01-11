package kha.gui;

import kha.Color;
import kha.Painter;
import kha.gui.Item;
import kha.gui.MouseEvent;

class Button extends Item {
	public function new(text: String, fontsize: Int = 15, width: Int = 125, height: Int = 37, normalcolor: Color = null, hovercolor: Color = null, normal: Item = null, hoveritem: Item = null, textpos: Float = 20) {
		super();
		width = 150;
		height = 25;
		this.text = text;
		
		if (normalcolor == null) normalcolor = Color.fromValue(0x574f46);
		if (hovercolor == null) hovercolor = Color.fromValue(0xffffff);
		
		textitem = new TextItem(text);
		hovering = false;
		this.normalcolor = normalcolor;
		this.hovercolor = hovercolor;
		//if (normal == null) this.normal = new NineZoneImage(Skin::the()->button(), 20, 20, 10, 10, width, height);
		//else this.normal = normal;

		//if (hoveritem == null) this.hoveritem = new NineZoneImage(Skin::the()->activebutton(), 20, 20, 10, 10, width, height);
		//else this.hoveritem = hoveritem;

		cursor = CursorStyle.Hand;
		textitem.cursor = CursorStyle.Hand;
		hover = true;
		textitem.setFontSize(fontsize);
		textitem.setPos(textpos, this.height / 2 - textitem.height / 2);
		textitem.setColor(normalcolor);
		add(textitem);
	}
	
	public var text: String;
	
	public var pressed: Void -> Void;
	
	override public function render(painter: Painter): Void {
		painter.setColor(77, 77, 77);
		painter.fillRect(0, 0, width, height);
		painter.setColor(177, 177, 177);
		painter.drawString(text, 5, 5);
	}

	override public function mouseDown(event: MouseEvent): Item {
		return this;
	}
	
	override public function mouseUp(event: MouseEvent): Void {
		pressed();
	}
	
	override public function mouseEnter(): Void {
		hovering = true;
		textitem.setColor(hovercolor);
	}
	
	override public function mouseLeave(): Void {
		hovering = false;
		textitem.setColor(normalcolor);
	}
	
	public function resetHover(): Void {
		hovering = false;
		textitem.setColor(normalcolor);
	}
	
	override private function getWidth(): Float {
		return normal.width;
	}
	
	override private function getHeight(): Float {
		return normal.height;
	}
	
	/*
	void Button::render(Painter* painter) {
		if (hovering) hover->render(painter);
		else normal->render(painter);
	}
	*/
	
	private var normal: Item;
	private var hoveritem: Item;
	private var textitem: TextItem;
	private var hovercolor: Color;
	private var normalcolor: Color;
	private var hovering: Bool;
}