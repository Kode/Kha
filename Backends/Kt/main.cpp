#include <Kt/stdafx.h>
#include <Kt/Application.h>
#include <Kt/Scene.h>
#include <Kt/Item.h>
#include <Kt/Input/Keyboard.h>
#include <Kt/Sound/Sound.h>
#include <stdio.h>
#include <kha/Starter.h>

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

	void keyDown(Kt::KeyEvent* event) {
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
}

int ktmain(const Kt::List<Kt::Text>& params) {
	// Do this first
	hxcpp_set_top_of_stack();

   // Register additional ndll libaries ...
   // nme_register_prims();
	Kt::Application app(params, 640, 520);
	Kt::Sound::init();
	//printf("Begin!\n");
 	const char *err = hxRunLibrary();
	if (err) {
		// Unhandled exceptions ...
		fprintf(stderr,"Error %s\n", err );
		return -1;
	}
	Kt::Keyboard::the()->KeyDown += keyDown;
	Kt::Keyboard::the()->KeyUp += keyUp;
	Kt::Scene::the()->add(Kt::Handle<HaxeItem>(new HaxeItem));
	app.start();
	//printf("Done!\n");
	return 0;
}