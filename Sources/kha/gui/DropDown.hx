package kha.gui;

import kha.gui.MouseEvent;
import kha.gui.Item;
import kha.Painter;

class DropDownCatcher extends Item {
	public function new() {
		
	}
	
	public var dropDown: DropDown = null;
	
	public var ddx = 0;
	
	public var ddy = 0;
	
	override public function render(painter: Painter): Void {
		var size = dropDown.items.length;
		painter.setColor(102, 102, 102);
		painter.fillRect(ddx, ddy, dropDown.width, size * 25);
		painter.setColor(177, 177, 177);
		for (i in 0...size) {
			painter.drawString(dropDown.items[i], ddx, ddy + i * 25);
		}
	}
	
	override public function mouseDown(event: MouseEvent): Item {
		var x = event.x;
		var y = event.y;
		var size = dropDown.items.length;
		if (x > ddx && x < ddx + dropDown.width && y > ddy && y < ddy + size * 25.0f) {
			var index = Std.int((y - ddy) / 25);
			dropDown.selected = index;
		}
		//layer()("objects")("remove:", self);
		return this;
	}
}

class DropDown extends Item {
	public function new() {
		width = 75;
		selected = 0;
		items = new Array<String>();
	}
	
	public var selected = 0;
	
	public var items: Array<String>;
	
	public function add(text: String): Void {
		items.push(text);
	}

	override public function render(painter: Painter): Void {
		String text = items[selected];
		painter.drawString(text, 5, 5);
	}

	override public function mouseDown(event: MouseEvent): Item {
		var catcher = new DropDownCatcher();
		catcher.width = Configuration.screen().width;
		catcher.height = Configuration.screen().height;
		catcher.dropDown = this;
		catcher.ddx = event.globalX - event.x + x;
		catcher.ddy = event.globalY - event.y + y;
		//layer()("objects")("add:", catcher);
		return this;
	}

DropDown(bool rollback = false, Color framecolor = Color(0, 0, 0), Color boxcolor = Color(0xff, 0xff, 0xff), Color hovercolor= Color(0xff, 0, 0), unsigned height = 42, Kt::Image button = Skin::the()->button(), Kt::Image activebutton = Skin::the()->activebutton());
		Color getFrameColor();
		Color getBoxColor();
		Color getHoverColor();
		unsigned getHeight();
		bool Rollback();
		void setLabel(Text name, unsigned size = 0, Color color = Color(0, 0, 0));
		void setFrameColor(Color color);
		void setBoxColor(Color color);
		void setHoverColor(Color color);
		void setHeight(unsigned height);
		float width();
		float itemswidth();
		float height();
		void render(Kt::Painter*);
		int index();
		void select(unsigned index);
		void addElement(Text name, unsigned fontSize = 0, Color fontColor = Color(0));
		void mouseButtonDown(MouseEvent*);
		void mouseEnter();
		void mouseLeave();
		unsigned count();
	private:
		List<TextItem*> elementitems;
		TextItem* myLabel;
		int myIndex;
		Color myFrameColor, myBoxColor, myHoverColor;
		unsigned myHeight;
		bool myRollBack, myhover;
		
		namespace {
	TextItem* pfeil = nullptr;
	NineZoneImage* back = nullptr;
}

DropDown::DropDown(bool rollback, Color framecolor, Color boxcolor, Color hovercolor, unsigned height, Kt::Image button, Kt::Image activebutton) : myIndex(0) {
	myRollBack = rollback;
	myFrameColor = framecolor;
	myBoxColor = boxcolor;
	myHoverColor = hovercolor;
	myHeight = height;
	setLabel("DropDown");
	if (pfeil == nullptr) {
	TextItem* text = new TextItem(L"▼");
	if (myRollBack) text->setFontSize(getHeight()/2);
	pfeil = text;
	}
	if (back == nullptr) back = new NineZoneImage(button, 20, 20, 10, 10, 100, myHeight);
}

Color DropDown::getFrameColor() {
	return myFrameColor;
}

Color DropDown::getBoxColor() {
	return myBoxColor;
}

unsigned DropDown::getHeight() {
	return myHeight;
}
Color DropDown::getHoverColor() {
	return myHoverColor;
}

float DropDown::itemswidth() {
	float max = 0;
	for (int i = 0; i < elementitems.size(); ++i) {
		if (elementitems[i]->width() > max) max = elementitems[i]->width();
	}
	if (Rollback() && (myLabel->width() > max)) max = myLabel->width();
	return max;
}

float DropDown::width() {
	if (Rollback()) {
		return myLabel->width() + 12;
	}
	else {
		return static_cast<float>(itemswidth() + 50);
	}
}

float DropDown::height() {
	if (elementitems.size() > 0) return elementitems[0]->height();
	return 0;
}

bool DropDown::Rollback() {
	return myRollBack;
}

unsigned DropDown::count() {
	return elementitems.size();
}

void DropDown::render(Painter* painter) {
	Kt::Vector2f trans = painter->getTranslation();
	back->setSize(static_cast<int>(width()), static_cast<int>(back->height()));
	back->render(painter);
	//painter->fillRect(0, 0, width() + 12, height(), 0xffffffff);
	//painter->drawRect(0, 0, width() + 12, height(), 0xff000000);
	if (elementitems.size() > index()) {
		if (!Rollback()) {
		painter->setTranslation(trans.x() + 15, trans.y() + 5);
		elementitems[index()]->render(painter);
		painter->setTranslation(trans.x() + itemswidth() + 15, trans.y() + 7);
		pfeil->render(painter);
		} else {
		if (myhover) {
			painter->fillRect(0, 2, width(), getHeight() - 4.0f, getHoverColor());
			painter->drawRect(0, 2, width(), getHeight() - 4.0f, Color(getHoverColor().Rb() - 0x22, getHoverColor().Gb() - 0x22, getHoverColor().Bb() - 0x22));
		}
		painter->setTranslation(trans.x() + 6, trans.y() + 2);
		myLabel->render(painter);
		}
	}
}


int DropDown::index() {
	return myIndex;
}

void DropDown::select(unsigned index) {
	myIndex = index;
}

void DropDown::addElement(Text name, unsigned fontsize, Color fontcolor) {
	if (fontsize == 0) fontsize = getHeight()/2;
	TextItem* text = new TextItem(name);
	text->setFontSize(fontsize);
	text->setColor(fontcolor);
	elementitems.push_back(text);
	elementitems.push_back(new TextItem(name));
}

void DropDown::setFrameColor(Color color) {
	myFrameColor = color;
}

void DropDown::setBoxColor(Color color) {
	myBoxColor = color;
}

void DropDown::setHeight(unsigned height) {
	myHeight = height;
}

void DropDown::setHoverColor(Color color) {
	myHoverColor = color;
}

void DropDown::setLabel(Text text, unsigned size, Color color) {
	TextItem* name = new TextItem(text);
	if (size == 0) size = getHeight()/2;
	name->setFontSize(size);
	name->setColor(color);
	myLabel = name;
}

class Kt::DownDrop : public Item {
public:
	int gap() {
		if (dad->Rollback()) {
			return dad->getHeight();
		}
		else {
			return 0;	
		}
	}

	DownDrop(DropDown* dad) : dad(dad), index(-1) {
		grabMouse();
	}

	~DownDrop() {
		ungrabMouse();
	}

	virtual float width() override {
		return dad->itemswidth() + 12.0f;
	}

	virtual float height() override {
		return dad->height() * dad->elementitems.size();
	}

	void render(Painter* painter) {
		Vector2f trans = painter->getTranslation();
		painter->fillRect(0, static_cast<float>(gap()), width(), height(), dad->getBoxColor());
		painter->drawRect(0, static_cast<float>(gap()), width(), height(), dad->getFrameColor());
		if (dad->Rollback()) {
			painter->fillRect(0, 2, dad->width(), height(), dad->getBoxColor());
			painter->drawRect(0, 2, dad->width(), height(), dad->getFrameColor());
			painter->setTranslation(trans.x() + 6, trans.y() + 2);
			TextItem* label = dad->myLabel;
			label->smudge();
			label->render(painter);
		}
		
		for (int i = 0; i < dad->elementitems.size(); ++i) {
			painter->setTranslation(trans.x() + 5, gap() + trans.y() + i * dad->height());
			if (index == static_cast<int>(i)) painter->fillRect(-4, 0, width() - 2, dad->height() - 1, dad->getHoverColor());
			dad->elementitems[i]->render(painter);
		}
	}

	int getIndex(int x, int y) {
		y -= gap();
		if (x > this->x() && x < this->x() + width() && y > this->y() && y < this->y() + height()) {
			return static_cast<int>((y - this->y()) / dad->height());
		}
		return -1;
	}

	void mouseMove(MouseEvent* e) {
		index = getIndex(e->x(), e->y());
	}

	void mouseButtonDown(MouseEvent* e) {
		if (!dad->Rollback() && (getIndex(e->x(), e->y()) >= 0)) dad->myIndex = static_cast<unsigned>(getIndex(e->x(), e->y()));
		Scene::the()->remove(this);
		delete this;
	}
private:
	DropDown* dad;
	int index;
};

void DropDown::mouseButtonDown(MouseEvent*) {
	Kt::Handle<DownDrop> drop(new DownDrop(this));
	float x = this->x();
	float y = this->y();
	Kt::Handle<Item> p = parent();
	while (!p.isNull()) {
		x += p->x();
		y += p->y();
		p = p->parent();
	}
	drop->setPos(x, y);
	Scene::the()->add(drop);
}

void DropDown::mouseEnter() {
	myhover = true;
}

void DropDown::mouseLeave() {
	myhover = false;
}
}