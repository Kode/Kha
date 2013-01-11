package kha.gui;
import kha.Painter;

class TextCursor extends Item {
	public function new() {
		width = 1;
		height = 20;
	}
	
	public var editor: TextEdit = null;
	
	override public function render(painter: Painter): Void {
		painter.setColor(0, 0, 0);
		painter.fillRect(0, 0, width, height);
	}
	
	/*
	void keyDown(KeyEvent* event) {
		Obj cursor = gui()("TextCursor");
		if (cursor("editor") == Object::Nil()) return;
		if (event->isChar()) {
			cursor("editor")("append:", Text(event->tochar()));
		}
	}

	void keyUp(KeyEvent* event) {

	}
	*/

	static Handle<TextCursor> the();
		void render(Painter* painter);
		float width();
		float height();
		void assign(TextEdit* edit);
		virtual void keyDown(Kt::KeyEvent* event) override;
		virtual void keyUp(Kt::KeyEvent* event) override;
		void setPos(Vector2i pos);
	private:
		TextCursor();
		Handle<TextEdit> edit;
		int pos;
		
Handle<TextCursor> TextCursor::the() {
	static Handle<TextCursor> instance(new TextCursor);
	return instance;
}

TextCursor::TextCursor() : pos(0) {
#ifdef _WIN32
	struct Func {
		Func(TextCursor* cursor) : cursor(cursor) { }
		void doit() {
			cursor->setVisible(!cursor->isVisible());
		}
		TextCursor* cursor;
	};
	Scheduler::addTimeTask(Function(Func(this), &Func::doit), 0, 0.5);
#endif
}

void TextCursor::render(Painter* painter) {
	if (!edit.isNull()) {
		painter->drawLine(0, 2, 0, static_cast<float>(edit->fontSize()), Color(0, 0, 0));
		painter->drawLine(1, 2, 1, static_cast<float>(edit->fontSize()), Color(0, 0, 0));
	}
}

float TextCursor::width() {
	return 2;
}

float TextCursor::height() {
	if (!edit.isNull()) return edit->height();
	return 20;
}

void TextCursor::assign(TextEdit* edit) {
	if (!this->edit.isNull()) this->edit->remove(the());
	pos = 0;
	setPos(Vector2i(0, 0));
	this->edit = edit;
	//edit->add(the()); //TODO
	//edit->reset();
	grabKeyboard();
}

void TextCursor::setPos(Vector2i pos) {
	Item::setPos(static_cast<float>(pos.x()), static_cast<float>(pos.y()));
}

void TextCursor::keyUp(Kt::KeyEvent* event) {

}

void TextCursor::keyDown(KeyEvent* e) {
	if (edit.isNull()) return;
	switch (e->keycode()) {
	//case Key_Enter:
	//	edit->Enter();
	//	return;
	case Key_Left:
		--pos;
		if (pos < 0) pos = 0;
		
		setPos(edit->posat(pos));
		return;
	case Key_Right:
		++pos;
		if (pos > static_cast<int>(edit->text().length())) pos = edit->text().length();
		setPos(edit->posat(pos));
		return;
	case Key_Delete:
		if (pos < static_cast<int>(edit->text().length())) edit->erase(pos);
		return;
	case Key_Backspace:
		if (pos > 0) {
			--pos;
			edit->erase(pos);
			setPos(edit->posat(pos));
		}
		return;
	}

	wchar_t c = e->tochar();
	if (c != 0) {
		edit->insert(pos, c);
		++pos;
		setPos(edit->posat(pos));
	}
}
}