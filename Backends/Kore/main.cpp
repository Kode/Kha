#include <Kore/pch.h>
#include <Kore/Application.h>
#include <Kore/Graphics/Graphics.h>
#include <Kore/Input/Gamepad.h>
#include <Kore/Input/Keyboard.h>
#include <Kore/Input/Mouse.h>
#include <Kore/Input/Sensor.h>
#include <Kore/Input/Surface.h>
#include <Kore/Audio/Audio.h>
#include <Kore/Audio/Mixer.h>
#include <Kore/IO/FileReader.h>
#include <Kore/Log.h>
#include <Kore/Threads/Mutex.h>
#include "jsmn.h"
#include <stdio.h>
#include <stdlib.h>
#include <kha/Starter.h>
#include <kha/Loader.h>
#include <kha/input/Sensor.h>
#include <kha/Sys.h>
#include <kha/ScreenRotation.h>
#include <kha/audio2/Audio.h>

#ifdef ANDROID
	#include <Kore/Vr/VrInterface.h>
#endif

extern "C" const char* hxRunLibrary();
extern "C" void hxcpp_set_top_of_stack();
void __hxcpp_register_current_thread();

namespace {
	using kha::Starter_obj;
	using kha::input::Sensor_obj;

	Kore::Mutex mutex;
	bool shift = false;
	
	void keyDown(Kore::KeyCode code, wchar_t character) {
		switch (code) {
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
			Starter_obj::pushChar(character);
			break;
		}
	}

	void keyUp(Kore::KeyCode code, wchar_t character) {
		switch (code) {
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
			Starter_obj::releaseChar(character);
			break;
		}
	}

	void mouseDown(int button, int x, int y) {
		Starter_obj::mouseDown(button, x, y);
	}

	void mouseUp(int button, int x, int y) {
		Starter_obj::mouseUp(button, x, y);
	}

	void mouseMove(int x, int y) {
		Starter_obj::mouseMove(x, y);
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

	void touchStart(int index, int x, int y) {
		Starter_obj::touchStart(index, x, y);
	}

	void touchEnd(int index, int x, int y) {
		Starter_obj::touchEnd(index, x, y);
	}

	void touchMove(int index, int x, int y) {
		Starter_obj::touchMove(index, x, y);
	}
	
	bool visible = true;

	void update() {
		Kore::Audio::update();
		if (visible) {
			#ifndef VR_RIFT
			Kore::Graphics::begin();
			#endif
			
			// Google Cardboard: Update the Distortion mesh
			#ifdef VR_CARDBOARD
			//	Kore::VrInterface::DistortionBefore();
			#endif

			Starter_obj::frame();

			#ifndef VR_RIFT
			Kore::Graphics::end();
			#endif
			
			// Google Cardboard: Call the DistortionMesh Renderer
			#ifdef VR_CARDBOARD
			//	Kore::VrInterface::DistortionAfter();
			#endif

			#ifndef VR_RIFT
			Kore::Graphics::swapBuffers();
			#endif
		}
	}
	
	void foreground() {
		visible = true;
		Starter_obj::foreground();
	}
	
	void resume() {
		Starter_obj::resume();
	}

	void pause() {
		Starter_obj::pause();
	}
	
	void background() {
		visible = false;
		Starter_obj::background();
	}
	
	void shutdown() {
		Starter_obj::shutdown();
	}
	
	void orientation(Kore::Orientation orientation) {
		switch (orientation) {
			case Kore::OrientationLandscapeLeft:
				::kha::Sys_obj::screenRotation = ::kha::ScreenRotation_obj::Rotation270;
				break;
			case Kore::OrientationLandscapeRight:
				::kha::Sys_obj::screenRotation = ::kha::ScreenRotation_obj::Rotation90;
				break;
			case Kore::OrientationPortrait:
				::kha::Sys_obj::screenRotation = ::kha::ScreenRotation_obj::RotationNone;
				break;
			case Kore::OrientationPortraitUpsideDown:
				::kha::Sys_obj::screenRotation = ::kha::ScreenRotation_obj::Rotation180;
				break;
			case Kore::OrientationUnknown:
				break;
		}
	}
	
	bool mixThreadregistered = false;

	void mix(int samples) {
		using namespace Kore;

#ifdef KORE_MULTITHREADED_AUDIO
		if (!mixThreadregistered) {
			__hxcpp_register_current_thread();
			mixThreadregistered = true;
		}
#endif

		::kha::audio2::Audio_obj::_callCallback(samples);

		for (int i = 0; i < samples; ++i) {
			float value = ::kha::audio2::Audio_obj::_readSample();
			*(float*)&Audio::buffer.data[Audio::buffer.writeLocation] = value;
			Audio::buffer.writeLocation += 4;
			if (Audio::buffer.writeLocation >= Audio::buffer.dataSize) Audio::buffer.writeLocation = 0;
		}
	}
}

int kore(int argc, char** argv) {
	Kore::log(Kore::Info, "Starting Kore");

	int width = 256;
	int height = 256;
	bool fullscreen = false;
	int antialiasing = 1;
	char name[256];
	name[0] = 0;
	
	{
		Kore::log(Kore::Info, "Reading project.kha");
		Kore::FileReader file("project.kha");
		int filesize = file.size();
		char* string = new char[filesize + 1];
		char* data = (char*)file.readAll();
		for (int i = 0; i < filesize; ++i) string[i] = data[i];
		string[filesize] = 0;

		jsmn_parser parser;
		jsmn_init(&parser);
		int size = jsmn_parse(&parser, string, filesize, nullptr, 0);
		jsmntok_t* tokens = new jsmntok_t[size];
		jsmn_init(&parser);
		size = jsmn_parse(&parser, string, filesize, tokens, size);

		for (int i = 0; i < size; ++i) {
			if (tokens[i].type == JSMN_STRING && strncmp("game", &string[tokens[i].start], tokens[i].end - tokens[i].start) == 0) {
				++i;
				int gamesize = tokens[i].size * 2;
				++i;
				int gamestart = i;
				for (; i < gamestart + gamesize; ++i) {
					if (tokens[i].type == JSMN_STRING && strncmp("name", &string[tokens[i].start], tokens[i].end - tokens[i].start) == 0) {
						++i;
						int ni = 0;
						for (int i2 = tokens[i].start; i2 < tokens[i].end; ++i2) {
							name[ni] = string[i2];
							++ni;
						}
						name[ni] = 0;
					}
					else if (tokens[i].type == JSMN_STRING && strncmp("width", &string[tokens[i].start], tokens[i].end - tokens[i].start) == 0) {
						++i;
						char number[25];
						int ni = 0;
						for (int i2 = tokens[i].start; i2 < tokens[i].end; ++i2) {
							number[ni] = string[i2];
							++ni;
						}
						number[ni] = 0;
						width = atoi(number);
					}
					else if (tokens[i].type == JSMN_STRING && strncmp("height", &string[tokens[i].start], tokens[i].end - tokens[i].start) == 0) {
						++i;
						char number[25];
						int ni = 0;
						for (int i2 = tokens[i].start; i2 < tokens[i].end; ++i2) {
							number[ni] = string[i2];
							++ni;
						}
						number[ni] = 0;
						height = atoi(number);
					}
					else if (tokens[i].type == JSMN_STRING && strncmp("antiAliasingSamples", &string[tokens[i].start], tokens[i].end - tokens[i].start) == 0) {
						++i;
						char number[25];
						int ni = 0;
						for (int i2 = tokens[i].start; i2 < tokens[i].end; ++i2) {
							number[ni] = string[i2];
							++ni;
						}
						number[ni] = 0;
						antialiasing = atoi(number);
					}
					else if (tokens[i].type == JSMN_STRING && strncmp("fullscreen", &string[tokens[i].start], tokens[i].end - tokens[i].start) == 0) {
						++i;
						fullscreen = strncmp("true", &string[tokens[i].start], tokens[i].end - tokens[i].start) == 0;
					}
				}

				break;
			}
		}
		
		delete[] tokens;
		delete string;
	}

	width = Kore::min(width, Kore::System::desktopWidth());
	height = Kore::min(height, Kore::System::desktopHeight());

	Kore::Application* app = new Kore::Application(argc, argv, width, height, fullscreen, name);
	//Kore::Mixer::init();
	mutex.Create();
	Kore::Audio::audioCallback = mix;
	Kore::Audio::init();
#ifndef VR_RIFT
	Kore::Graphics::setRenderState(Kore::DepthTest, false);
#endif
	app->orientationCallback = orientation;
	app->foregroundCallback = foreground;
	app->resumeCallback = resume;
	app->pauseCallback = pause;
	app->backgroundCallback = background;
	app->shutdownCallback = shutdown;
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
	Kore::Mouse::the()->Press = mouseDown;
	Kore::Mouse::the()->Release = mouseUp;
	Kore::Mouse::the()->Move = mouseMove;
	Kore::Gamepad::get(0)->Axis = gamepadAxis;
	Kore::Gamepad::get(0)->Button = gamepadButton;
	Kore::Surface::the()->TouchStart = touchStart;
	Kore::Surface::the()->TouchEnd = touchEnd;
	Kore::Surface::the()->Move = touchMove;
	Kore::Sensor::the(Kore::SensorAccelerometer)->Changed = accelerometerChanged;
	Kore::Sensor::the(Kore::SensorGyroscope)->Changed = gyroscopeChanged;


#ifdef VR_GEAR_VR
	// Enter VR mode
	Kore::VrInterface::Initialize();
#endif

	Kore::log(Kore::Info, "Starting application");
	app->start();
	Kore::log(Kore::Info, "Application stopped");

	return 0;
}
