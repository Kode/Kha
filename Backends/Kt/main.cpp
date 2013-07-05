#include <Kt/stdafx.h>
#include <Kt/Application.h>
#include <Kt/Scene.h>
#include <Kt/Item.h>
#include <Kt/Input/Keyboard.h>
#include <Kt/Input/Mouse.h>
#include <Kt/Sound/Sound.h>
#include <Kt/Files/File.h>
#include <Kt/Files/Json.h>
#include <Kt/Files/TextReader.h>
#include <stdio.h>
#include <kha/Starter.h>
#include <kha/Loader.h>

extern "C" const char *hxRunLibrary();
extern "C" void hxcpp_set_top_of_stack();

Kt::Painter* haxePainter;

namespace {
	using kha::Starter_obj;

	class HaxeItem : public Kt::Item {
	public:
		float width() {
			return 640;
		}

		float height() {
			return 520;
		}

		virtual void mouseButtonDown(Kt::MouseEvent* event) override {
			Starter_obj::mouseDown(event->x(), event->y());
		}

		virtual void mouseButtonUp(Kt::MouseEvent* event) override {
			Starter_obj::mouseUp(event->x(), event->y());
		}

		virtual void mouseMove(Kt::MouseEvent* event) override {
			Starter_obj::mouseMove(event->x(), event->y());
		}

		void render(Kt::Painter* painter) {
			haxePainter = painter;
			Starter_obj::frame();
		}
	};

	bool shiftDown = false;

	void keyDown(Kt::KeyEvent* event) {
		if (event->isChar()) {
			if (shiftDown) Starter_obj::pushChar((int)Kt::Char(event->tochar()).toUpper().value);
			else Starter_obj::pushChar((int)Kt::Char(event->tochar()).toLower().value);
		}
		else {
			switch (event->keycode()) {
			case Kt::Key_Backspace:
				Starter_obj::backspaceDown();
				break;
			case Kt::Key_Tab:
				Starter_obj::tabDown();
				break;
			case Kt::Key_Enter:
				Starter_obj::enterDown();
				break;
			case Kt::Key_Shift:
				shiftDown = true;
				Starter_obj::shiftDown();
				break;
			case Kt::Key_Control:
				Starter_obj::controlDown();
				break;
			case Kt::Key_Alt:
				Starter_obj::altDown();
				break;
			case Kt::Key_Escape:
				Starter_obj::escapeDown();
				break;
			case Kt::Key_Delete:
				Starter_obj::deleteDown();
				break;
			}
		}
		switch (event->keycode()) {
		case Kt::Key_Up:
			Starter_obj::pushUp();
			break;
		case Kt::Key_Down:
			Starter_obj::pushDown();
			break;
		case Kt::Key_Left:
			Starter_obj::pushLeft();
			break;
		case Kt::Key_Right:
			Starter_obj::pushRight();
			break;
		case Kt::Key_A:
			Starter_obj::pushButton1();
			break;
		}
	}

	void keyUp(Kt::KeyEvent* event) {
		if (event->isChar()) {
			if (shiftDown) Starter_obj::releaseChar((int)Kt::Char(event->tochar()).toUpper().value);
			else Starter_obj::releaseChar((int)Kt::Char(event->tochar()).toLower().value);
		}
		else {
			switch (event->keycode()) {
			case Kt::Key_Backspace:
				Starter_obj::backspaceUp();
				break;
			case Kt::Key_Tab:
				Starter_obj::tabUp();
				break;
			case Kt::Key_Enter:
				Starter_obj::enterUp();
				break;
			case Kt::Key_Shift:
				shiftDown = false;
				Starter_obj::shiftUp();
				break;
			case Kt::Key_Control:
				Starter_obj::controlUp();
				break;
			case Kt::Key_Alt:
				Starter_obj::altUp();
				break;
			case Kt::Key_Escape:
				Starter_obj::escapeUp();
				break;
			case Kt::Key_Delete:
				Starter_obj::deleteUp();
				break;
			}
		}
		switch (event->keycode()) {
		case Kt::Key_Up:
			Starter_obj::releaseUp();
			break;
		case Kt::Key_Down:
			Starter_obj::releaseDown();
			break;
		case Kt::Key_Left:
			Starter_obj::releaseLeft();
			break;
		case Kt::Key_Right:
			Starter_obj::releaseRight();
			break;
		case Kt::Key_A:
			Starter_obj::releaseButton1();
			break;
		}
	}

	void mouseDown(Kt::MouseEvent event) {
		Starter_obj::mouseDown(event.x(), event.y());
	}

	void mouseUp(Kt::MouseEvent event) {
		Starter_obj::mouseUp(event.x(), event.y());
	}

	void mouseMove(Kt::MouseEvent event) {
		Starter_obj::mouseMove(event.x(), event.y());
	}
}

int ktmain(const Kt::List<Kt::Text>& params) {
	int width;
	int height;
	Kt::Text name;
	
	{
		Kt::DiskFile file("project.kha", Kt::DiskFile::MODE_READ);
		Kt::TextReader reader(&file);
		Kt::Json::Data json(reader.readAll());
		Kt::Json::Value& game = json["game"];
		name = game["name"].string();
		width = game["width"].number();
		height = game["height"].number();
	}

	Kt::Application app(params, width, height, false, name.c_str(), false);
	Kt::Sound::init();
	Kt::System::showWindow();

	hxcpp_set_top_of_stack();

	const char* err = hxRunLibrary();
	if (err) {
		fprintf(stderr, "Error %s\n", err);
		return 1;
	}

	Kt::Keyboard::the()->KeyDown += keyDown;
	Kt::Keyboard::the()->KeyUp += keyUp;
	Kt::Mouse::the()->MouseDown += mouseDown;
	Kt::Mouse::the()->MouseUp += mouseUp;
	Kt::Mouse::the()->MouseMove += mouseMove;
	Kt::Scene::the()->add(Kt::Handle<HaxeItem>(new HaxeItem));
	app.start();
	return 0;
}
