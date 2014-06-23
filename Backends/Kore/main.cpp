#include <Kore/pch.h>
#include <Kore/Application.h>
#include <Kore/Graphics/Graphics.h>
#include <Kore/Input/Gamepad.h>
#include <Kore/Input/Keyboard.h>
#include <Kore/Input/KeyEvent.h>
#include <Kore/Input/Mouse.h>
#include <Kore/Input/Sensor.h>
#include <Kore/Audio/Audio.h>
#include <Kore/Audio/Mixer.h>
#include <Kore/IO/FileReader.h>
#include <Kore/Log.h>
#include "Json.h"
#include <stdio.h>
#include <kha/Starter.h>
#include <kha/Loader.h>
#include <kha/input/Sensor.h>
#include <kha/Sys.h>
#include <kha/ScreenRotation.h>

extern "C" const char* hxRunLibrary();
extern "C" void hxcpp_set_top_of_stack();

namespace {
	using kha::Starter_obj;
	using kha::input::Sensor_obj;

	bool shift = false;
	
	void keyDown(Kore::KeyEvent* event) {
		switch (event->keycode()) {
		case Kore::Key_Up:
			Starter_obj::pushUp();
			break;
		case Kore::Key_Down:
			Starter_obj::pushDown();
			break;
		case Kore::Key_Left:
			Starter_obj::pushLeft();
			break;
		case Kore::Key_Right:
			Starter_obj::pushRight();
			break;
		case Kore::Key_Space:
			Starter_obj::pushChar(' ');
			break;
		case Kore::Key_Shift:
			Starter_obj::pushShift();
			shift = true;
			break;
		case Kore::Key_Backspace:
			Starter_obj::pushBackspace();
			break;
		case Kore::Key_Tab:
			Starter_obj::pushTab();
			break;
		case Kore::Key_Enter:
		case Kore::Key_Return:
			Starter_obj::pushEnter();
			break;
		case Kore::Key_Control:
			Starter_obj::pushControl();
			break;
		case Kore::Key_Alt:
			Starter_obj::pushAlt();
			break;
		case Kore::Key_Escape:
			Starter_obj::pushEscape();
			break;
		case Kore::Key_Delete:
			Starter_obj::pushDelete();
			break;
		default:
			Starter_obj::pushChar(shift ? event->tochar() : event->tochar() + 'a' - 'A');
			break;
		}
	}

	void keyUp(Kore::KeyEvent* event) {
		switch (event->keycode()) {
		case Kore::Key_Up:
			Starter_obj::releaseUp();
			break;
		case Kore::Key_Down:
			Starter_obj::releaseDown();
			break;
		case Kore::Key_Left:
			Starter_obj::releaseLeft();
			break;
		case Kore::Key_Right:
			Starter_obj::releaseRight();
			break;
		case Kore::Key_Space:
			Starter_obj::releaseChar(' ');
			break;
		case Kore::Key_Shift:
			Starter_obj::releaseShift();
			shift = false;
			break;
		case Kore::Key_Backspace:
			Starter_obj::releaseBackspace();
			break;
		case Kore::Key_Tab:
			Starter_obj::releaseTab();
			break;
		case Kore::Key_Enter:
		case Kore::Key_Return:
			Starter_obj::releaseEnter();
			break;
		case Kore::Key_Control:
			Starter_obj::releaseControl();
			break;
		case Kore::Key_Alt:
			Starter_obj::releaseAlt();
			break;
		case Kore::Key_Escape:
			Starter_obj::releaseEscape();
			break;
		case Kore::Key_Delete:
			Starter_obj::releaseDelete();
			break;
		default:
			Starter_obj::releaseChar(shift ? event->tochar() : event->tochar() + 'a' - 'A');
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

	void middleMouseDown(Kore::MouseEvent event) {
		Starter_obj::middleMouseDown(event.x(), event.y());
	}

	void middleMouseUp(Kore::MouseEvent event) {
		Starter_obj::middleMouseUp(event.x(), event.y());
	}

	void accelerometerChanged(float x, float y, float z) {
		Sensor_obj::_changed(0, x, y, z);
	}

	void gyroscopeChanged(float x, float y, float z) {
		Sensor_obj::_changed(1, x, y, z);
	}

	void gamepadAxis(int axis, float value) {
		Starter_obj::gamepadAxis(axis, value);
	}

	void gamepadButton(int button, float value) {
		Starter_obj::gamepadButton(button, value);
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
	Kore::log(Kore::Info, "Starting Kore");

	int width;
	int height;
	std::string name;
	
	{
		Kore::log(Kore::Info, "Reading project.kha");
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
	Kore::Graphics::setRenderState(Kore::DepthTest, false);
	app->setCallback(update);
	
	Kore::log(Kore::Info, "Initializing Haxe libraries");
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
	Kore::Mouse::the()->PressMiddle = middleMouseDown;
	Kore::Mouse::the()->ReleaseMiddle = middleMouseUp;
	Kore::Mouse::the()->Move = mouseMove;
	Kore::Gamepad::get(0)->Axis = gamepadAxis;
	Kore::Gamepad::get(0)->Button = gamepadButton;
	Kore::Sensor::the(Kore::SensorAccelerometer)->Changed = accelerometerChanged;
	Kore::Sensor::the(Kore::SensorGyroscope)->Changed = gyroscopeChanged;

	Kore::log(Kore::Info, "Starting application");
#ifdef SYS_IOS
	::kha::Sys_obj::screenRotation = ::kha::ScreenRotation_obj::Rotation270;
#endif
	app->start();
	Kore::log(Kore::Info, "Application stopped");

	return 0;
}
