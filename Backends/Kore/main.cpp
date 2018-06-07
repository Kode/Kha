#include <Kore/pch.h>
//#include <Kore/Application.h>
#include <Kore/Graphics4/Graphics.h>
#include <Kore/Input/Gamepad.h>
#include <Kore/Input/Keyboard.h>
#include <Kore/Input/Mouse.h>
#include <Kore/Input/Pen.h>
#include <Kore/Input/Sensor.h>
#include <Kore/Input/Surface.h>
#include <Kore/Audio2/Audio.h>
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
	//#include <Kore/Vr/VrInterface.h>
#endif

extern "C" const char* hxRunLibrary();
extern "C" void hxcpp_set_top_of_stack();
void __hxcpp_register_current_thread();

namespace {
	using kha::SystemImpl_obj;
	using kha::input::Sensor_obj;

	Kore::Mutex mutex;
	bool shift = false;
	
	void keyDown(Kore::KeyCode code) {
		SystemImpl_obj::keyDown((int)code);
	}

	void keyUp(Kore::KeyCode code) {
		SystemImpl_obj::keyUp((int)code);
	}

	void keyPress(wchar_t character) {
		SystemImpl_obj::keyPress(character);
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

	void mouseLeave(int windowId) {
		SystemImpl_obj::mouseLeave(windowId);
	}

	void penDown(int windowId, int x, int y, float pressure) {
		SystemImpl_obj::penDown(windowId, x, y, pressure);
	}

	void penUp(int windowId, int x, int y, float pressure) {
		SystemImpl_obj::penUp(windowId, x, y, pressure);
	}

	void penMove(int windowId, int x, int y, float pressure) {
		SystemImpl_obj::penMove(windowId, x, y, pressure);
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
		Kore::Audio2::update();

		int windowCount = Kore::System::windowCount();

		for (int windowIndex = 0; windowIndex < windowCount; ++windowIndex) {
			if (visible) {
				#ifndef VR_RIFT
				Kore::Graphics4::begin(windowIndex);
                #endif
			
				// Google Cardboard: Update the Distortion mesh
				#ifdef VR_CARDBOARD
				//	Kore::VrInterface::DistortionBefore();
				#endif

                SystemImpl_obj::frame(windowIndex);

				#ifndef VR_RIFT
                Kore::Graphics4::end(windowIndex);
				#endif
			
				// Google Cardboard: Call the DistortionMesh Renderer
				#ifdef VR_CARDBOARD
				//	Kore::VrInterface::DistortionAfter();
				#endif

				#ifndef VR_RIFT
				if (!Kore::Graphics4::swapBuffers(windowIndex)) {
					Kore::log(Kore::Error, "Graphics context lost.");
					break;
				}
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

	void dropFiles(wchar_t* filePath) {
		SystemImpl_obj::dropFiles(String(filePath));
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
			*(float*)&Audio2::buffer.data[Audio2::buffer.writeLocation] = value;
			Audio2::buffer.writeLocation += 4;
			if (Audio2::buffer.writeLocation >= Audio2::buffer.dataSize) Audio2::buffer.writeLocation = 0;
		}
	}

	char cutCopyString[4096];

	char* copy() {
		strcpy(cutCopyString, SystemImpl_obj::copy().c_str());
		return cutCopyString;
	}

	char* cut() {
		strcpy(cutCopyString, SystemImpl_obj::cut().c_str());
		return cutCopyString;
	}

	void paste(char* data) {
		SystemImpl_obj::paste(String(data));
	}
}

void init_kore_impl(bool ex, const char* name, int width, int height, int x, int y, int display, Kore::WindowMode windowMode, int antialiasing, bool vSync, bool resizable, bool maximizable, bool minimizable) {
	Kore::log(Kore::Info, "Starting Kore");

	Kore::Random::init(static_cast<int>(Kore::System::timestamp() % std::numeric_limits<int>::max()));
	Kore::System::setName(name);
	Kore::System::setup();

	if (ex) {

	}
	else {
		width = Kore::min(width, Kore::System::desktopWidth());
		height = Kore::min(height, Kore::System::desktopHeight());

		Kore::WindowOptions options;
		options.title = name;
		options.width = width;
		options.height = height;
		options.x = x;
		options.y = y;
		options.vSync = vSync;
		options.targetDisplay = display;
		options.mode = windowMode;
		options.resizable = resizable;
		options.maximizable = maximizable;
		options.minimizable = minimizable;
		options.rendererOptions.depthBufferBits = 16;
		options.rendererOptions.stencilBufferBits = 8;
		options.rendererOptions.textureFormat = 0;
		options.rendererOptions.antialiasing = antialiasing;

		/*int windowId =*/ Kore::System::initWindow(options); // TODO (DK) save window id anywhere?
	}

	//Kore::Mixer::init();
	mutex.create();

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
	Kore::System::setDropFilesCallback(dropFiles);
	Kore::System::setCallback(update);
	Kore::System::setCopyCallback(copy);
	Kore::System::setCutCallback(cut);
	Kore::System::setPasteCallback(paste);

	Kore::Keyboard::the()->KeyDown = keyDown;
	Kore::Keyboard::the()->KeyUp = keyUp;
	Kore::Keyboard::the()->KeyPress = keyPress;
	Kore::Mouse::the()->Press = mouseDown;
	Kore::Mouse::the()->Release = mouseUp;
	Kore::Mouse::the()->Move = mouseMove;
	Kore::Mouse::the()->Scroll = mouseWheel;
	Kore::Mouse::the()->Leave = mouseLeave;
	Kore::Pen::the()->Press = penDown;
	Kore::Pen::the()->Release = penUp;
	Kore::Pen::the()->Move = penMove;
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

const char* getGamepadId(int index) {
	return Kore::Gamepad::get(index)->productName;
}

void init_kore(const char* name, int width, int height, int antialiasing, bool vSync, int windowMode, bool resizable, bool maximizable, bool minimizable) {
	init_kore_impl(false, name, width, height, -1, -1, -1, (Kore::WindowMode)windowMode, antialiasing, vSync, resizable, maximizable, minimizable);
}

void init_kore_ex(const char* name) {
	init_kore_impl(true, name, -1, -1, -1, -1, -1, Kore::WindowModeWindow, 0, false, false, false, true);
}

void post_kore_init() {
	// (DK) make main window context current, all assets bind to it and are shared
	Kore::System::makeCurrent(0);

	Kore::Audio2::audioCallback = mix;
	Kore::Audio2::init();

#ifdef VR_GEAR_VR
	// Enter VR mode
	Kore::VrInterface::Initialize();
#endif
}

int init_window(Kore::WindowOptions options) {
	return Kore::System::initWindow(options);
}

void run_kore() {
	Kore::log(Kore::Info, "Starting application");
	Kore::System::start();
	Kore::log(Kore::Info, "Application stopped");
#if !defined(KORE_XBOX_ONE) && !defined(KORE_TIZEN) && !defined(KORE_HTML5)
	Kore::System::stop();
#endif
}

int kore(int argc, char** argv) {
	Kore::log(Kore::Info, "Initializing Haxe libraries");
	hxcpp_set_top_of_stack();
	const char* err = hxRunLibrary();
	if (err) {
		Kore::log(Kore::Error, "Error %s", err);
		return 1;
	}
	return 0;
}
