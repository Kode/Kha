package kha.gui;

import kha.Color;
import kha.graphics2.Graphics;
import kha.Image;

class TextItem extends Item {
	public function new(text: String = "") {
		super();
		mytext = text;
		myWidth = 0;
		dirty = true;
		mysize = defaultsize;
		myfont = defaultfile;
		color = Color.fromBytes(255, 0, 0);
		myOpacity = 1; 
	}
	
	private var mytext: String;
	private var dirty: Bool;
	private var mysize: Int;
	private var myfont: String;
	private var myOpacity: Float;
	private var pixmap: Image;
	//List<Hyperlink> mylinks;
	//List<Kt::Handle<Item> > items;
	private var color: Color;
	
	public static var defaultfile: String = "arial.ttf";
	public static var defaultsize = 23;

	public function setDefault(filename: String, size: Int): Void {
		defaultfile = filename;
		defaultsize = size;
	}

	override private function get_width(): Float {
		if (myWidth > 0) return myWidth;
		//if (fonts.find(pair<Text, int>(myfont, mysize)) == fonts.end()) fonts[pair<Text, int>(myfont, mysize)] = new Font(myfont, mysize);
		//return fonts[pair<Text, int>(myfont, mysize)]->width(mytext);
		return 50;
	}

	override private function get_height(): Float {
		//if (mywidth > 0) {
		//	if (fonts.find(pair<Text, int>(myfont, mysize)) == fonts.end()) fonts[pair<Text, int>(myfont, mysize)] = new Font(myfont, mysize);
		//	return fonts[pair<Text, int>(myfont, mysize)]->height(mytext, static_cast<real>(mywidth));
		//}
		//if (fonts.find(pair<Text, int>(myfont, mysize)) == fonts.end()) fonts[pair<Text, int>(myfont, mysize)] = new Font(myfont, mysize);
		//return fonts[pair<Text, int>(myfont, mysize)]->height();
		return 50;
	}
	
	override public function render(g: Graphics): Void {
		//mylinks.clear();
		//if (fonts.find(pair<Text, int>(myfont, mysize)) == fonts.end()) fonts[pair<Text, int>(myfont, mysize)] = new Font(myfont, mysize);
		//fonts[pair<Text, int>(myfont, mysize)]->render(painter, mytext, 0, 0, color, static_cast<real>(mywidth)); //&mylinks, &items);
		g.drawString(text, 0, 0);
	}

	public var text(get, set): String;
	
	private function get_text(): String {
		return mytext;
	}
	
	private function set_text(text: String): String {
		mytext = text;
		dirty = true;
		return mytext;
	}
	
	public function setColor(col: Color): Void {
		color = col;
		dirty = true;
	}

	public function setFont(font: String): Void {
		myfont = font;
		dirty = true;
	}

	public function setTextWidth(width: Int): Void {
		myWidth = width;
		dirty = true;
	}

	public function setFontSize(size: Int): Void {
		mysize = size;
		dirty = true;
	}

	//const List<Hyperlink>& TextItem::links() {
	//	return mylinks;
	//}

	public function setOpacity(opacity: Float): Void {
		myOpacity = opacity;
		//color = Color(color.Rb(), color.Gb(), color.Bb(), static_cast<u8>(opacity * 255));
	}

	/*void TextItem::addTextItem(Kt::Handle<Item> item) {
		items.push_back(item);
		add(item);
		dirty = true;
	}*/

	public function smudge(): Void {
		dirty = true;
	}
}