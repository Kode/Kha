package kha.gui;
import kha.gui.MouseEvent;
import kha.gui.Item;
import kha.Painter;

class ScrollBarHandle extends Item {
	public function new() {
		width = 20;
		height = 40;
	}
	
	public var dragged = false;

	public var yoffset = 0;
	
	public var area: Scroller;
	
	override public function render(painter: Painter): Void {
		painter.setColor(64, 64, 64);
		painter.fillRect(0, 0, width, height);
	}

	override public function mouseDown(event: MouseEvent): Item {
		dragged = true;
		yoffset = event.y - y;
		return this;
	}
	
	override public function mouseMove(event: MouseEvent): Void {
		if (dragged) {
			var ypos = event.y - yoffset;
			var handleHeight = height;
			var barHeight = area.bar.height;
			ypos = Math.max(0, ypos);
			ypos = Math.min(ypos, barHeight - handleHeight);
			y = ypos;
			var yrel = ypos / (barHeight - handleHeight);
			var contentHeight = area.content.height - barHeight;
			area.moveTo(-yrel * contentHeight);
		}
	}

	override public function mouseUp(event: MouseEvent): Void {
		dragged = false;
	}

	public function arrange(): Void {
		var contentHeight = area.content.height;
		var barHeight = area.bar.height;
		var handleHeight = barHeight * (barHeight / contentHeight);
		height = handleHeight;
	}
	
	ScrollBarHandle(ScrollArea* scroller, int buttonwidth);
		float width();
		float height();
		float trueHeight();
		float overlap();
		int pictheightvalues(Text which);	
		float buttonHeight();
		void render(Painter* painter);
		void setHeight(int height, int overhead = 0);
		void setX(int x);
		void setBarPos(float x, float y);
		void setStart(int start);
		void setOverhead(float x);
		void checkOverhead(int hheight);
		void setEnd(int end);
		void mouseMove(MouseEvent*);
		void mouseEnter();
		void mouseLeave();
		void mouseButtonDown(MouseEvent*);
		void up();
		void down();
		void checkPos();
	private:
		int myX, myHeight, start, end, myOverlap, myTrueHeight, myButtonWidth;
		float myButtonHeight;
		ScrollArea* scroller;
		bool hover;
		Kt::Image top;
	    Kt::Image bottom ;
	    Kt::Image body;
		Kt::Image midhover;
		Kt::Image midnohover;
	
	ScrollBarHandle::ScrollBarHandle(ScrollArea* scroller, int width) : scroller(scroller), hover(false) {
	myOverlap = 0;
	myHeight = 50;
	myTrueHeight= 50;
	moveable = true;
	myButtonWidth = width;
	myButtonHeight = static_cast<float>(Skin::the()->scrollbarup().Height());
	top = Skin::the()->sbtop();
	bottom = Skin::the()->sbbot();
	body = Skin::the()->sbbod();
	midhover = Skin::the()->sbmid_hover();
	midnohover = Skin::the()->sbmid_nohover();
	cursor = Kt::HAND_CURSOR;
}

float ScrollBarHandle::width() {
	return static_cast<float>(myButtonWidth);
}

float ScrollBarHandle::buttonHeight() {
	return myButtonHeight;
}

float ScrollBarHandle::overlap() {
	return static_cast<real>(myOverlap);
}

int ScrollBarHandle::pictheightvalues(Text which){
	if (which == "borders") { 
	return top.Height() + bottom.Height();
	} else if (which == "body") {
	return body.Height();
	} else if (which == "top") {
	return top.Height();
	} else if (which == "bottom") {
	return bottom.Height();
	} else if (which == "hover") {
	return midhover.Height();
	} else {
		return 0;
	}
}

float ScrollBarHandle::trueHeight() {
	return static_cast<real>(myTrueHeight - 1);
}

float ScrollBarHandle::height() {
	return static_cast<real>(myHeight - 1);
}

//QRectF ScrollBarHandle::boundingRect() const {
//	return QRectF(0, -1, 19, height - 1);
//}

void ScrollBarHandle::render(Painter* painter) {
	int bot = 0;
	painter->drawImage(top, 0, 0);
	for (int i = top.Height(); i <= myTrueHeight - bottom.Height(); i = i + body.Height()) {
		painter->drawImage(body, 0, static_cast<float>(i));
		bot = i + body.Height();
	}
	
	if (bot < top.Height() + body.Height()) {
		if (bot == 0) bot = top.Height(); 
	}
	else if (bot >= top.Height() + midhover.Height()) {
		if (hover) {
			painter->drawImage(bottom, 0, static_cast<float>(bot));
			painter->drawImage(midhover, 0, trueHeight()/2 - midhover.Height()/2);
		}
		else {
			painter->drawImage(midnohover, 0, trueHeight()/2 - midnohover.Height()/2);
		}
	}
	painter->drawImage(bottom, 0, static_cast<float>(bot));
	
	/*painter->fillRect(10, 0, width() - 1, trueHeight(), myColors[2]);
	painter->drawRect(10, 0, width() - 1, trueHeight(), myColors[3]);
	painter->fillRect(20, 0, width() - 1, overlap(), myColors[2]);
	painter->drawRect(20, 0, width() - 1, overlap(), myColors[3]);
	unsigned pen;
	if (hover) pen = myColors[5]; //pen = QPen(Qt::white, 2);
	else pen = myColors[4]; //pen = QPen(QColor(69, 62, 55), 2);
	float strichabstand = 6;
	painter->drawLine(strichabstand, -1 + height() / 2 - 4, width() - strichabstand, -1 + height() / 2 - 4, pen);
	painter->drawLine(strichabstand, -1 + height() / 2, width() - strichabstand, -1 + height() / 2, pen);
	painter->drawLine(strichabstand, -1 + height() / 2 + 4, width() - strichabstand, -1 + height() / 2 + 4, pen);
	*/
}
void ScrollBarHandle::mouseEnter() {
	hover = true;
}

void ScrollBarHandle::mouseLeave() {
	hover = false;
}

void ScrollBarHandle::setHeight(int height, int overhead) {
	myHeight = height + overhead;
	myTrueHeight = height;
}

void ScrollBarHandle::setX(int x) {
	myX = x;
}

void ScrollBarHandle::setBarPos(float x, float y) {
		setPos(x, y - overlap());
	}

void ScrollBarHandle::setOverhead(float x) {
	myOverlap = static_cast<int>(x);
}


void ScrollBarHandle::setStart(int start) {
	this->start = start;
}

void ScrollBarHandle::setEnd(int end) {
	this->end = end;
}

void ScrollBarHandle::mouseMove(MouseEvent*) {
	checkPos();
}

void ScrollBarHandle::mouseButtonDown(MouseEvent*) {

}

void ScrollBarHandle::up() {
	if (!scroller->isActive()) return;
	setBarPos(x(), y() + overlap() - 10);
	checkPos();
}

void ScrollBarHandle::down() {
	if (!scroller->isActive()) return;
	setBarPos(x(), y() + overlap() + 10);
	checkPos();
}

void ScrollBarHandle::checkPos() {
	setBarPos(static_cast<real>(myX), y() + overlap());
	if (y() + overlap() < start) setBarPos(static_cast<real>(myX), static_cast<real>(start));
	if (y() + overlap() + trueHeight() > end) setBarPos(static_cast<real>(myX), end - (trueHeight()));
	scroller->setScrollPos((static_cast<real>(y() + overlap() - start) / static_cast<real>(end - start)), false);
}
}