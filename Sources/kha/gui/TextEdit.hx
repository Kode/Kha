package kha.gui;
import kha.gui.MouseEvent;
import kha.gui.Item;
import kha.Painter;

class TextEdit extends Item {
	public function new() {
		
	}
	
	public var text: String = "";
	
	override public function render(painter: Painter): Void {
		painter.setColor(255, 255, 255);
		painter.fillRect(0, 0, width, height);
		painter.setColor(0, 0, 0);
		painter.drawString(text, 10, 20);
	}
	
	override public function mouseDown(event: MouseEvent): Item {
		var cursor = new TextCursor();
		cursor.editor = this;
		return this;
	}

	public function append(value: String): Void {
		text = text + value;
	}
	
TextEdit();
		TextEdit(Text text, bool removeTextOnClick = false);
		float width();
		float height();
		void render(Painter* painter);
		void setText(Text text);
		void setColor(Color col);
		void setBackColor(Color backcol);
		void setFont(Text font);
		void setFontSize(int size);
		int fontSize();
		void setOpacity(float opacity);
		Text text();
		void mouseButtonDown(Kt::MouseEvent*);
		Vector2i posat(int pos);
		void insert(int pos, wchar_t c);
		void erase(int pos);
		void reset();
		virtual void fixWidth(int width);
		void setPassMode();
		void keyDown(KeyEvent* e);
		void keyUp(KeyEvent* e);
		void setActive(bool active);
		static void setDefault(Kt::Text filename, int size);
		Delegate0 Enter;
	protected:
		//void render();
		float myOpacity;
		bool dirty;
		Image pixmap;
	private:
		Text mytext;
		int mysize;
		Text myfont;
		Color color;
		int fixedWidth;
		bool passmode;
		Color backcolor;
		bool myRemoveTextOnClick;
		bool myActive;
		List<Vector2i> positions;
		
namespace {
	Kt::Text defaultfile = L"arial.ttf";
	int defaultsize = 23;
}

TextEdit::TextEdit() : dirty(true), mysize(defaultsize), myfont(defaultfile), color(0), myOpacity(1), fixedWidth(0), passmode(false), backcolor(0xffffffff), myRemoveTextOnClick(false), myActive(true) {
	
}

TextEdit::TextEdit(Text text, bool removeTextOnClick) : mytext(text), dirty(true), mysize(defaultsize), myfont(defaultfile), color(0), myOpacity(1), fixedWidth(0), passmode(false), backcolor(0xffffffff), myRemoveTextOnClick(removeTextOnClick), myActive(true) {

}

void TextEdit::setDefault(Kt::Text filename, int size) {
	defaultfile = filename;
	defaultsize = size;
}

float TextEdit::width() {
	//if (dirty) render();
	//if (fixedWidth > 0) return static_cast<float>(fixedWidth);
	//return static_cast<float>(pixmap.Width());
	return 200;
}

float TextEdit::height() {
	//if (dirty) render();
	//return static_cast<float>(pixmap.Height());
	return 50;
}

void TextEdit::render(Painter* painter) {
	//if (dirty) render();
	painter->fillRect(0, 0, width(), height(), backcolor);
	painter->drawRect(0, 0, width(), height(), Color(0, 0, 0));
	/*if (pixmap.Width() > 0) {
		painter->setOpacity(myOpacity);
		painter->drawImage(pixmap, 0, 0);
	}*/
	if (fonts.find(pair<Text, int>(myfont, mysize)) == fonts.end()) fonts[pair<Text, int>(myfont, mysize)] = new Font(myfont, mysize);
	fonts[pair<Text, int>(myfont, mysize)]->render(painter, mytext, 0, 0);
}

Text TextEdit::text() {
	return mytext;
}

void TextEdit::setColor(Color col) {
	color = col;
	dirty = true;
}

void TextEdit::setBackColor(Color backcol) {
	backcolor = backcol;
}

void TextEdit::setFont(Text font) {
	myfont = font;
	dirty = true;
}

void TextEdit::setText(Text text) {
	mytext = text;
	dirty = true;
}

void TextEdit::setFontSize(int size) {
	mysize = size;
	dirty = true;
}

int TextEdit::fontSize() {
	return mysize;
}
/*
void TextEdit::render() {
	if (fonts.find(pair<Text, int>(myfont, mysize)) == fonts.end()) fonts[pair<Text, int>(myfont, mysize)] = new Font(myfont, mysize);
	Text string = mytext;
	if (passmode) {
		string = L"";
		for (unsigned i = 0; i < mytext.length(); ++i) string += L'*';
	}
	if (fixedWidth > 0) pixmap = fonts[pair<Text, int>(myfont, mysize)]->render(string, color, fixedWidth, nullptr, nullptr, &positions);
	else pixmap = fonts[pair<Text, int>(myfont, mysize)]->render(string, color, &positions);
	//int h = pixmap->height();
	dirty = false;
}
*/
void TextEdit::keyDown(KeyEvent* e) {
	if (!myActive) return;
	if (e->keycode() == Kt::Key_Backspace) mytext = mytext.substring(0, 1);
	else if (e->keycode() == Kt::Key_Enter || e->keycode() == Kt::Key_Return) mytext += L'\n';
	else mytext = mytext + Char(e->tochar());
	dirty = true;
}

void TextEdit::keyUp(KeyEvent* e) {

}

void TextEdit::setActive(bool active) {
	myActive = active;
}

void TextEdit::setOpacity(float opacity) {
	myOpacity = opacity;
}

void TextEdit::mouseButtonDown(Kt::MouseEvent*) {
	if (myRemoveTextOnClick) reset();
	TextCursor::the()->assign(this);
	//grabKeyboard();
}

Vector2i TextEdit::posat(int pos) {
	if (mytext == L"") return Vector2i(0, 0);
	//if (dirty) render();
	return positions[pos];
}

void TextEdit::insert(int pos, wchar_t c) {
	Text string;
	string += c;
	mytext.insert(pos, string);
	dirty = true;
}

void TextEdit::erase(int pos) {
	mytext.erase(pos, 1);
	dirty = true;
}

void TextEdit::reset() {
	mytext = L"";
	dirty = true;
}

void TextEdit::fixWidth(int width) {
	fixedWidth = width;
}

void TextEdit::setPassMode() {
	passmode = true;
	dirty = true;
}
}