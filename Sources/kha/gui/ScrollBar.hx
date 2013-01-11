package kha.gui;

import kha.Painter;

class DownButton : public RepeatButton {
public:
	DownButton(Handle<ScrollBarHandle> handle) : RepeatButton(Skin::the()->scrollbardown(), handle) {
		
	}

	void doit() {
		handle->down();
	}
};

class UpButton : public RepeatButton {
public:
	UpButton(Handle<ScrollBarHandle> handle) : RepeatButton(Skin::the()->scrollbarup(), handle) {
		
	}

	void doit() {
		handle->up();
	}

};

class ScrollBar extends Item {
	public function new() {
		x = 380;
		width = 20;
		height = 400;
		handle = new ScrollBarHandle();
		children.push(handle);
	}
	
	public var handle: ScrollBarHandle;
	
	public var area: Scroller;

	override public function render(painter: Painter): Void {
		painter.setColor(38, 38, 38);
		painter.fillRect(0, 0, width, height);
	}

	public function arrange(): Void {
		x = area.width - 20;
		handle.arrange();
	}
	
	ScrollBar(int width, Color color, Color lcolor);
		void setHeight(int height);
		float width();
		float height();
		void render(Painter* painter);
	protected:
		int myHeight, scrollBarWidth;
		Color SBColor, LColor;

ScrollBar::ScrollBar(int width, Color color, Color lcolor) {
	scrollBarWidth = width;
	SBColor = color;
	LColor = lcolor;
}

void ScrollBar::setHeight(int height) {
	myHeight = height;
}

float ScrollBar::width() {
	return static_cast<real>(scrollBarWidth);
}

float ScrollBar::height() {
	return static_cast<real>(myHeight) - scrollBarWidth * 2;
}

//QRectF ScrollBar::boundingRect() const {
//	return QRectF(0, 19, 19, height - 19 * 2);
//}

void ScrollBar::render(Painter* painter) {
	painter->fillRect(0, static_cast<real>(scrollBarWidth), width(), height(), SBColor);
	painter->drawLine(0, static_cast<real>(scrollBarWidth), 0, scrollBarWidth + height(), LColor);
	painter->drawLine(width() - 1, static_cast<real>(scrollBarWidth), width() - 1, scrollBarWidth + height(), LColor);
}
}