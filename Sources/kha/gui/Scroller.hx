package kha.gui;
import kha.Painter;

class Scroller extends Item {
	public function new() {
		width = 400;
		height = 400;
		clipping = true;
		content = new ScrollContent();
		bar = new ScrollBar();
		children.push(content);
		children.push(bar);
		bar.area = this;
		bar.handle.area = this;
	}
	
	public var transx = 0;
	
	public var transy = 0;
	
	public var content: ScrollContent;
	
	public var bar: ScrollBar;
	
	override public function render(painter: Painter): Void {
		painter.setColor(51, 51, 51);
		painter.fillRect(0, 0, width, height);
	}

	public function add(item: Item): Void {
		content.add(item);
	}
	
	public function moveTo(y: Int): Void {
		content.y = y;
	}
	
	public function arrange(): Void {
		bar.arrange();
	}

ScrollArea(Handle<Item> child, bool showalways = false, bool greyish = false, int scrollBarWidth = 19, std::vector<Color> colors = std::vector<Color>(0));
		float width();
		float height();
		void render(Painter* painter);
		void resize(int width, int height, int bottomclip = 0);
		void setScrollPos(real pos, bool checkhandle = true);
		void setScrollPosAbs(real pos);
		void updateBar();
		bool isScrollBarVisible();
		void resetPos();
		bool isActive();
		float getPosition();
		int getWidth();
	private:
		Handle<Item> child;
		int myWidth;
		int myHeight;
		float position;
		Handle<Item> downButton, upButton;
		Handle<ScrollBarHandle> handle;
		bool active;
		bool showalways;
		bool greyish;
	protected:
		Handle<ScrollBar> scrollBar;
	};

	class RepeatButton : public ImageItem {
	public:
		RepeatButton(Image image, Handle<ScrollBarHandle> handle) : ImageItem(image), handle(handle), pressed(false) {
			//setZValue(4);
			cursor = Kt::HAND_CURSOR;
		}

		void mouseButtonDown(Kt::MouseEvent*) {
			pressed = true;
			doit();
#ifdef _WIN32
			struct Func {
				Func(RepeatButton* button) : button(button) { }
				void doit() {
					if (button->pressed) button->doit();
				}
				RepeatButton* button;
			};
			timer = Scheduler::addTimeTask(Function(Func(this), &Func::doit), 0.4, 0.1);
#endif
		}

		void mouseButtonUp(Kt::MouseEvent*) {
			pressed = false;
#ifdef _WIN32
			Scheduler::removeTimeTask(timer);
#endif
		}

		virtual void doit() = 0;
	protected:
		Handle<ScrollBarHandle> handle;
	private:
		Scheduler::Id timer;
		bool pressed;

ScrollArea::ScrollArea(Handle<Item> child, bool showalways, bool greyish, int scrollBarWidth, std::vector<Color> colors) : child(child), position(0), active(true), showalways(showalways), greyish(greyish) {
	//setFlag(QGraphicsItem::ItemClipsChildrenToShape);
	clip = true;
	add(child);

	//Filling missing colora with default values
	switch (colors.size()) {
	case 0:
		colors.push_back(Color(0xf0, 0xee, 0xec));
    case 1:
		colors.push_back(Color(0xff, 0xff, 0xff));
	}
	//child->setZValue(0);
		handle = new ScrollBarHandle(this, scrollBarWidth);
	downButton = new DownButton(handle);
	upButton = new UpButton(handle);
	scrollBar = new ScrollBar(scrollBarWidth, colors[0], colors[1]);
}

float ScrollArea::width() {
	return static_cast<real>(myWidth);
}

float ScrollArea::height() {
	return static_cast<real>(myHeight);
}

void ScrollArea::render(Painter* painter) {
	if (greyish) {
		painter->fillRect(0, 0, width(), height(), Color(0xf0, 0xee, 0xec));
		painter->drawLine(0, 0, width() - 23, 0, Color(0xd7, 0xd3, 0xcf));
		painter->drawLine(0, 1, width() - 23, 1, Color(0xd7, 0xd3, 0xcf));
		painter->drawLine(0, 2, width() - 23, 2, Color(0xff, 0xff, 0xff));
		painter->drawLine(0, height() - 2, width() - 23, height() - 2, Color(0xd7, 0xd3, 0xcf));
		painter->drawLine(0, height() - 1, width() - 23, height() - 1, Color(0xd7, 0xd3, 0xcf));
	}
}

void ScrollArea::resize(int width, int height, int bottomclip) {
	myWidth = width;
	myHeight = height - bottomclip;
	scrollBar->setHeight(height);
	upButton->setPos(width - downButton->width(), 0);
	downButton->setPos(width - downButton->width(), height - downButton->height());
	scrollBar->setPos(width - scrollBar->width(), 0);
	add(scrollBar);
	add(upButton);
	add(downButton);
	int start = static_cast<int>(upButton->height());
	int end = static_cast<int>(height - downButton->height() + 1);
	float posy = position * (end - start) + start;
	int hheight = static_cast<int>(this->height() / child->height() * (end - start)) - 2;
	float overhead; 
	if (hheight < handle->pictheightvalues("borders") + handle->pictheightvalues("body")) {
		overhead = handle->pictheightvalues("borders") - 1.0f;
	}
	else {
		overhead = handle->pictheightvalues("body") - ((hheight - handle->pictheightvalues("borders")) % handle->pictheightvalues("body")) + 2.0f;
	}
	handle ->setOverhead(((posy - handle->buttonHeight()) / ((end - start) - hheight)) * overhead);
	handle->setX(static_cast<int>(width - handle->width() + 0));
	handle->setStart(start);
	handle->setEnd(end);
	handle->setHeight(hheight, static_cast<int>(overhead));
	handle->setBarPos(width - handle->width() + 0, posy);
	add(handle);
	
	if (height >= child->height()) {
		active = false;
		child->setPos(0, 0);
		if (showalways) {
			scrollBar->setVisible(true);
			upButton->setVisible(true);
			downButton->setVisible(true);
			scrollBar->setVisible(true);
		}
		else {
			scrollBar->setVisible(false);
			upButton->setVisible(false);
			downButton->setVisible(false);
			scrollBar->setVisible(false);
		}
		handle->setVisible(false);
	}
	else {
		active = true;
		scrollBar->setVisible(true);
		upButton->setVisible(true);
		downButton->setVisible(true);
		scrollBar->setVisible(true);
		handle->setVisible(true);
	}
}

void ScrollArea::setScrollPos(real pos, bool checkhandle) {
	position = pos;
	child->setPos(child->x(), -child->height() * pos);
	updateBar();
	if (checkhandle) handle->checkPos();
}

void ScrollArea::setScrollPosAbs(real pos) {
	setScrollPos(pos / child->height());
}

void ScrollArea::updateBar() {
	resize(myWidth, myHeight);
}

bool ScrollArea::isScrollBarVisible() {
	return scrollBar->isVisible();
}

void ScrollArea::resetPos() {
	setScrollPos(0);
}

bool ScrollArea::isActive() {
	return active;
}

float ScrollArea::getPosition() {
	return child->height() * position;
}

int ScrollArea::getWidth() {
	return myWidth;
}
}