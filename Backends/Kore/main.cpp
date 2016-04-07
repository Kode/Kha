#include <Kore/pch.h>
//#include <Kore/Application.h>
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
#include <Kore/Math/Random.h>
#include <kha/SystemImpl.h>
#include <kha/input/Sensor.h>
#include <kha/ScreenRotation.h>
#include <kha/audio2/Audio.h>

#include <limits>
#include <stdio.h>
#include <stdlib.h>

#ifdef ANDROID
	#include <Kore/Vr/VrInterface.h>
#endif

extern "C" const char* hxRunLibrary();
extern "C" void hxcpp_set_top_of_stack();
void __hxcpp_register_current_thread();

namespace {
	using kha::SystemImpl_obj;
	using kha::input::Sensor_obj;

	Kore::Mutex mutex;
	bool shift = false;
	
	void keyDown(Kore::KeyCode code, wchar_t character) {
		switch (code) {
		case Kore::Key_Up:
			SystemImpl_obj::pushUp();
			break;
		case Kore::Key_Down:
			SystemImpl_obj::pushDown();
			break;
		case Kore::Key_Left:
			SystemImpl_obj::pushLeft();
			break;
		case Kore::Key_Right:
			SystemImpl_obj::pushRight();
			break;
		case Kore::Key_Space:
			SystemImpl_obj::pushChar(' ');
			break;
		case Kore::Key_Shift:
			SystemImpl_obj::pushShift();
			shift = true;
			break;
		case Kore::Key_Backspace:
			SystemImpl_obj::pushBackspace();
			break;
		case Kore::Key_Tab:
			SystemImpl_obj::pushTab();
			break;
		case Kore::Key_Enter:
		case Kore::Key_Return:
			SystemImpl_obj::pushEnter();
			break;
		case Kore::Key_Control:
			SystemImpl_obj::pushControl();
			break;
		case Kore::Key_Alt:
			SystemImpl_obj::pushAlt();
			break;
		case Kore::Key_Escape:
			SystemImpl_obj::pushEscape();
			break;
		case Kore::Key_Delete:
			SystemImpl_obj::pushDelete();
			break;
		case Kore::Key_Back:
			SystemImpl_obj::pushBack();
			break;
		default:
			SystemImpl_obj::pushChar(character);
			break;
		}
	}

	void keyUp(Kore::KeyCode code, wchar_t character) {
		switch (code) {
		case Kore::Key_Up:
			SystemImpl_obj::releaseUp();
			break;
		case Kore::Key_Down:
			SystemImpl_obj::releaseDown();
			break;
		case Kore::Key_Left:
			SystemImpl_obj::releaseLeft();
			break;
		case Kore::Key_Right:
			SystemImpl_obj::releaseRight();
			break;
		case Kore::Key_Space:
			SystemImpl_obj::releaseChar(' ');
			break;
		case Kore::Key_Shift:
			SystemImpl_obj::releaseShift();
			shift = false;
			break;
		case Kore::Key_Backspace:
			SystemImpl_obj::releaseBackspace();
			break;
		case Kore::Key_Tab:
			SystemImpl_obj::releaseTab();
			break;
		case Kore::Key_Enter:
		case Kore::Key_Return:
			SystemImpl_obj::releaseEnter();
			break;
		case Kore::Key_Control:
			SystemImpl_obj::releaseControl();
			break;
		case Kore::Key_Alt:
			SystemImpl_obj::releaseAlt();
			break;
		case Kore::Key_Escape:
			SystemImpl_obj::releaseEscape();
			break;
		case Kore::Key_Delete:
			SystemImpl_obj::releaseDelete();
			break;
		case Kore::Key_Back:
			SystemImpl_obj::releaseBack();
			break;
		default:
			SystemImpl_obj::releaseChar(character);
			break;
		}
	}

	void mouseDown(int windowId, int button, int x, int y) {
		SystemImpl_obj::mouseDown(windowId, button, x, y);
	}

	void mouseUp(int windowId, int button, int x, int y) {
		SystemImpl_obj::mouseUp(windowId, button, x, y);
	}

	void mouseMove(int windowId, int x, int y, int movementX, int movementY) {
		SystemImpl_obj::mouseMove(windowId, x, y, movementX, movementY);
	}

	void mouseWheel(int windowId, int delta) {
		SystemImpl_obj::mouseWheel(windowId, delta);
	}

	void accelerometerChanged(float x, float y, float z) {
		Sensor_obj::_changed(0, x, y, z);
	}

	void gyroscopeChanged(float x, float y, float z) {
		Sensor_obj::_changed(1, x, y, z);
	}

	void gamepad1Axis(int axis, float value) {
		SystemImpl_obj::gamepad1Axis(axis, value);
	}

	void gamepad1Button(int button, float value) {
		SystemImpl_obj::gamepad1Button(button, value);
	}

	void gamepad2Axis(int axis, float value) {
		SystemImpl_obj::gamepad2Axis(axis, value);
	}

	void gamepad2Button(int button, float value) {
		SystemImpl_obj::gamepad2Button(button, value);
	}

	void gamepad3Axis(int axis, float value) {
		SystemImpl_obj::gamepad3Axis(axis, value);
	}

	void gamepad3Button(int button, float value) {
		SystemImpl_obj::gamepad3Button(button, value);
	}

	void gamepad4Axis(int axis, float value) {
		SystemImpl_obj::gamepad4Axis(axis, value);
	}

	void gamepad4Button(int button, float value) {
		SystemImpl_obj::gamepad4Button(button, value);
	}

	void touchStart(int index, int x, int y) {
		SystemImpl_obj::touchStart(index, x, y);
	}

	void touchEnd(int index, int x, int y) {
		SystemImpl_obj::touchEnd(index, x, y);
	}

	void touchMove(int index, int x, int y) {
		SystemImpl_obj::touchMove(index, x, y);
	}
	
	bool visible = true;
	bool paused = false;

	void update() {
		if (paused) return;
		Kore::Audio::update();

		int windowCount = Kore::System::windowCount();

		for (int windowIndex = 0; windowIndex < windowCount; ++windowIndex) {
			if (visible) {
				#ifndef VR_RIFT
				Kore::Graphics::begin(windowIndex);
                #endif
			
				// Google Cardboard: Update the Distortion mesh
				#ifdef VR_CARDBOARD
				//	Kore::VrInterface::DistortionBefore();
				#endif

                SystemImpl_obj::frame(windowIndex);

				#ifndef VR_RIFT
                Kore::Graphics::end(windowIndex);
				#endif
			
				// Google Cardboard: Call the DistortionMesh Renderer
				#ifdef VR_CARDBOARD
				//	Kore::VrInterface::DistortionAfter();
				#endif

				#ifndef VR_RIFT
				Kore::Graphics::swapBuffers(windowIndex);
				#endif
			}
		}
	}
	
	void foreground() {
		visible = true;
		SystemImpl_obj::foreground();
	}
	
	void resume() {
		SystemImpl_obj::resume();
		paused = false;
	}

	void pause() {
		SystemImpl_obj::pause();
		paused = true;
	}
	
	void background() {
		visible = false;
		SystemImpl_obj::background();
	}
	
	void shutdown() {
		SystemImpl_obj::shutdown();
	}
	
	void orientation(Kore::Orientation orientation) {
		/*switch (orientation) {
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
		}*/
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

void init_kore_impl(bool ex, const char* name, int width, int height, int x, int y, int display, Kore::WindowMode windowMode, int antialiasing) {
	Kore::log(Kore::Info, "Starting Kore");

	Kore::Random::init(static_cast<int>(Kore::System::timestamp() % std::numeric_limits<int>::max()));
	Kore::System::setName(name);
	Kore::System::setup();

	if (ex) {
	} else {
		width = Kore::min(width, Kore::System::desktopWidth());
		height = Kore::min(height, Kore::System::desktopHeight());

		Kore::WindowOptions options;
		options.title = "";
		options.width = width;
		options.height = height;
		options.x = x;
		options.y = y;
		options.targetDisplay = display;
		options.mode = windowMode;
		options.rendererOptions.depthBufferBits = 16;
		options.rendererOptions.stencilBufferBits = 8;
		options.rendererOptions.textureFormat = 0;
		options.rendererOptions.antialiasing = antialiasing;

		/*int windowId =*/ Kore::System::initWindow(options); // TODO (DK) save window id anywhere?
	}

	//Kore::Mixer::init();
	mutex.Create();

	// (DK) moved to post_kore_init
//#ifndef VR_RIFT
//	Kore::Graphics::setRenderState(Kore::DepthTest, false);
//#endif

	Kore::System::setOrientationCallback(orientation);
	Kore::System::setForegroundCallback(foreground);
	Kore::System::setResumeCallback(resume);
	Kore::System::setPauseCallback(pause);
	Kore::System::setBackgroundCallback(background);
	Kore::System::setShutdownCallback(shutdown);
	Kore::System::setCallback(update);

	Kore::Keyboard::the()->KeyDown = keyDown;
	Kore::Keyboard::the()->KeyUp = keyUp;
	Kore::Mouse::the()->Press = mouseDown;
	Kore::Mouse::the()->Release = mouseUp;
	Kore::Mouse::the()->Move = mouseMove;
	Kore::Mouse::the()->Scroll = mouseWheel;
	Kore::Gamepad::get(0)->Axis = gamepad1Axis;
	Kore::Gamepad::get(0)->Button = gamepad1Button;
	Kore::Gamepad::get(1)->Axis = gamepad2Axis;
	Kore::Gamepad::get(1)->Button = gamepad2Button;
	Kore::Gamepad::get(2)->Axis = gamepad3Axis;
	Kore::Gamepad::get(2)->Button = gamepad3Button;
	Kore::Gamepad::get(3)->Axis = gamepad4Axis;
	Kore::Gamepad::get(3)->Button = gamepad4Button;
	Kore::Surface::the()->TouchStart = touchStart;
	Kore::Surface::the()->TouchEnd = touchEnd;
	Kore::Surface::the()->Move = touchMove;
	Kore::Sensor::the(Kore::SensorAccelerometer)->Changed = accelerometerChanged;
	Kore::Sensor::the(Kore::SensorGyroscope)->Changed = gyroscopeChanged;

	// (DK) moved to post_kore_init
//#ifdef VR_GEAR_VR
//	// Enter VR mode
//	Kore::VrInterface::Initialize();
//#endif
}

void init_kore(const char* name, int width, int height, int antialiasing) {
	init_kore_impl(false, name, width, height, -1, -1, -1, Kore::WindowModeWindow, antialiasing);
}

void init_kore_ex( const char * name ) {
	init_kore_impl(true, name, -1, -1, -1, -1, -1, Kore::WindowModeWindow, 0);
}

void post_kore_init() {
	// (DK) make main window context current, all assets bind to it and are shared
	Kore::System::makeCurrent(0);

#ifndef VR_RIFT
	Kore::Graphics::setRenderState(Kore::DepthTest, false);
#endif

	Kore::Audio::audioCallback = mix;
	Kore::Audio::init();

#ifdef VR_GEAR_VR
	// Enter VR mode
	Kore::VrInterface::Initialize();
#endif
}

int
init_window( Kore::WindowOptions options ) {
	return Kore::System::initWindow(options);
}

void run_kore() {
	Kore::log(Kore::Info, "Starting application");
	Kore::System::start();
	Kore::log(Kore::Info, "Application stopped");
}

int kore(int argc, char** argv) {
	Kore::log(Kore::Info, "Initializing Haxe libraries");
	hxcpp_set_top_of_stack();
	const char* err = hxRunLibrary();
	if (err) {
		fprintf(stderr, "Error %s\n", err);
		return 1;
	}
	return 0;
}
