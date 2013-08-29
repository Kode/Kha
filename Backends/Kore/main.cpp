#include <Kore/pch.h>
#include <Kore/Application.h>
#include <Kore/Graphics/Graphics.h>
#include <Kore/Input/Keyboard.h>
#include <Kore/Input/KeyEvent.h>
#include <Kore/Input/Mouse.h>
#include <Kore/Audio/Audio.h>
#include <Kore/Audio/Mixer.h>
#include <Kore/IO/FileReader.h>
#include "Json.h"
#include <stdio.h>
#include <kha/Starter.h>
#include <kha/Loader.h>

extern "C" const char* hxRunLibrary();
extern "C" void hxcpp_set_top_of_stack();

namespace {
	using kha::Starter_obj;

	void keyDown(Kore::KeyEvent* event) {
		switch (event->keycode()) {
		case Kore::Key_Up:
		case Kore::Key_W:
			Starter_obj::pushUp();
			break;
		case Kore::Key_Down:
			Starter_obj::pushDown();
			break;
		case Kore::Key_Left:
		case Kore::Key_A:
			Starter_obj::pushLeft();
			break;
		case Kore::Key_Right:
		case Kore::Key_D:
			Starter_obj::pushRight();
			break;
		/*case Kore::Key_A:
			Starter_obj::pushButton1();
			break;*/
		case Kore::Key_Space:
			Starter_obj::pushChar(' ');
			break;
		case Kore::Key_Shift:
			Starter_obj::pushShift();
			break;
		}
	}

	void keyUp(Kore::KeyEvent* event) {
		switch (event->keycode()) {
		case Kore::Key_Up:
		case Kore::Key_W:
			Starter_obj::releaseUp();
			break;
		case Kore::Key_Down:
			Starter_obj::releaseDown();
			break;
		case Kore::Key_Left:
		case Kore::Key_A:
			Starter_obj::releaseLeft();
			break;
		case Kore::Key_Right:
		case Kore::Key_D:
			Starter_obj::releaseRight();
			break;
		/*case Kore::Key_A:
			Starter_obj::releaseButton1();
			break;*/
		case Kore::Key_Space:
			Starter_obj::releaseChar(' ');
			break;
		case Kore::Key_Shift:
			Starter_obj::releaseShift();
			break;
		}
	}

	void mouseDown(Kore::MouseEvent event) {
		Starter_obj::mouseDown(event.x(), event.y());
	}

	void mouseUp(Kore::MouseEvent event) {
		Starter_obj::mouseUp(event.x(), event.y());
	}

	void mouseMove(Kore::MouseEvent event) {
		Starter_obj::mouseMove(event.x(), event.y());
	}

	void rightMouseDown(Kore::MouseEvent event) {
		Starter_obj::rightMouseDown(event.x(), event.y());
	}

	void rightMouseUp(Kore::MouseEvent event) {
		Starter_obj::rightMouseUp(event.x(), event.y());
	}

	void update() {
		Kore::Audio::update();
		Kore::Graphics::begin();
		Starter_obj::frame();
		Kore::Graphics::end();
		Kore::Graphics::swapBuffers();
	}
}

int kore(int argc, char** argv) {
	int width;
	int height;
	std::string name;
	
	{
		Kore::FileReader file("project.kha");
		int filesize = file.size();
		char* string = new char[filesize + 1];
		char* data = (char*)file.readAll();
		for (int i = 0; i < filesize; ++i) string[i] = data[i];
		string[filesize] = 0;
		Json::Data json(string);
		Json::Value& game = json["game"];
		name = game["name"].string();
		width = game["width"].number();
		height = game["height"].number();
		delete string;
	}

	Kore::Application* app = new Kore::Application(argc, argv, width, height, false, name.c_str());
	Kore::Mixer::init();
	Kore::Audio::init();
	app->setCallback(update);
	
	hxcpp_set_top_of_stack();

	const char* err = hxRunLibrary();
	if (err) {
		fprintf(stderr, "Error %s\n", err);
		return 1;
	}

	Kore::Keyboard::the()->KeyDown = keyDown;
	Kore::Keyboard::the()->KeyUp = keyUp;
	Kore::Mouse::the()->PressLeft = mouseDown;
	Kore::Mouse::the()->ReleaseLeft = mouseUp;
	Kore::Mouse::the()->PressRight = rightMouseDown;
	Kore::Mouse::the()->ReleaseRight = rightMouseUp;
	Kore::Mouse::the()->Move = mouseMove;

	app->start();

	return 0;
}
