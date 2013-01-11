package kha.gui;

class ListLayout {
	public function new() 
	{
		
	}
	
	ListLayout(bool center = false);
		float width();
		float height();
		void render(Painter* painter);
		void addWidget(Handle<Item> item);
		unsigned addWidgetAt(Kt::Handle<Item> item, float y);
		void positionItems();
		void removeWidget(Handle<Item> item);

		Kt::Handle<Item> getItem(unsigned index);
		unsigned count();
	public:
		List<Handle<Item> > items;
	private:
		float myWidth, myHeight;
		bool center;

namespace {
	const int spacing = 5;
}

ListLayout::ListLayout(bool center) : myWidth(100), center(center) {

}

float ListLayout::width() {
	return myWidth;
}

float ListLayout::height() {
	return myHeight;
}

void ListLayout::render(Painter*) {

}

void ListLayout::addWidget(Handle<Item> item) {
	add(item);
	items.push_back(item);
	positionItems();
}

void ListLayout::positionItems() {
    //prepareGeometryChange();
	myWidth = 0;
	myHeight = 2;

	FOR_EACH (Handle<Item>, item, items) {
		if ((*item)->width() > myWidth) myWidth = (*item)->width();
		(*item)->setPos(0, myHeight);
		myHeight += (*item)->height() + spacing;
	}
	myHeight -= spacing;

	if (center) {
		FOR_EACH (Handle<Item>, item, items) {
			(*item)->setPos(width() / 2 - (*item)->width() / 2, (*item)->y());
		}
	}

	//update();
}

void ListLayout::removeWidget(Handle<Item> item) {
	//item->setVisible(false);
    FOR_EACH (Handle<Item>, it, items) {
            if (*it == item) {
                    items.erase(it);
                    break;
            }
    }
	remove(item);
	positionItems();
}

Handle<Item> ListLayout::getItem(unsigned index) {
	return items[index];
}

unsigned ListLayout::count() {
	return items.size();
}

unsigned ListLayout::addWidgetAt(Handle<Item> item, float y) {
	add(item);

	if (y <= items.front()->y() + items.front()->height() / 2) {
		items.insert(items.begin(), item);
		positionItems();
		return 0;
	}
	if (y >= items.back()->y() + items.back()->height() / 2) {
		items.push_back(item);
		positionItems();
		return items.size() - 1;
	}
	unsigned i = 1;
	FOR_EACH (Handle<Item>, it, items) {
		if (y >= (*it)->y() + (*it)->height() / 2 && it + 1 != items.end() && y <= (*(it + 1))->y() + (*(it + 1))->height() / 2) {
			items.insert(it + 1, item);
			positionItems();
			return i;
		}
		++i;
	}
	return 0;
}
}