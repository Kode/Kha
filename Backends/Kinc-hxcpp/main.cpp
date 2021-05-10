#include <khalib/loader.h>

#include <kinc/audio2/audio.h>
#include <kinc/graphics4/graphics.h>
#include <kinc/input/acceleration.h>
#include <kinc/input/gamepad.h>
#include <kinc/input/keyboard.h>
#include <kinc/input/mouse.h>
#include <kinc/input/pen.h>
#include <kinc/input/rotation.h>
#include <kinc/input/surface.h>
#include <kinc/io/filereader.h>
#include <kinc/log.h>
#include <kinc/math/random.h>
#include <kinc/threads/mutex.h>
#include <kinc/threads/thread.h>
#if HXCPP_API_LEVEL >= 332
#include <hxinc/kha/SystemImpl.h>
#include <hxinc/kha/audio2/Audio.h>
#include <hxinc/kha/input/Sensor.h>
#else
#include <kha/SystemImpl.h>
#include <kha/audio2/Audio.h>
#include <kha/input/Sensor.h>
#endif

#include <limits>
#include <stdio.h>
#include <stdlib.h>

#ifdef ANDROID
//#include <Kore/Vr/VrInterface.h>
#endif

namespace {
	using kha::SystemImpl_obj;
	using kha::input::Sensor_obj;

	kinc_mutex_t mutex;
	bool shift = false;

	void keyDown(int code) {
		SystemImpl_obj::keyDown(code);
	}

	void keyUp(int code) {
		SystemImpl_obj::keyUp(code);
	}

	void keyPress(unsigned int character) {
		SystemImpl_obj::keyPress((int)character);
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

	void gamepadAxis(int gamepad, int axis, float value) {
		SystemImpl_obj::gamepadAxis(gamepad, axis, value);
	}

	void gamepadButton(int gamepad, int button, float value) {
		SystemImpl_obj::gamepadButton(gamepad, button, value);
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
		//**if (paused) return;
		kinc_a2_update();

		SystemImpl_obj::frame();

		/*int windowCount = Kore::Window::count();

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


		    }
		}*/

#ifndef VR_RIFT
		if (!kinc_g4_swap_buffers()) {
			kinc_log(KINC_LOG_LEVEL_ERROR, "Graphics context lost.");
		}
#endif
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

	void dropFiles(wchar_t *filePath) {
		SystemImpl_obj::dropFiles(String(filePath));
	}

#if defined(HXCPP_TELEMETRY) || defined(HXCPP_PROFILER) || defined(HXCPP_DEBUG)
	const static bool gcInteractionStrictlyRequired = true;
#else
	const static bool gcInteractionStrictlyRequired = false;
#endif
	bool mixThreadregistered = false;

	void mix(kinc_a2_buffer_t *buffer, int samples) {
		using namespace Kore;

		int t0 = 99;
#ifdef KORE_MULTITHREADED_AUDIO
		if (!mixThreadregistered && !::kha::audio2::Audio_obj::disableGcInteractions) {
			hx::SetTopOfStack(&t0, true);
			mixThreadregistered = true;
			hx::EnterGCFreeZone();
		}

		// int addr = 0;
		// Kore::log(Info, "mix address is %x", &addr);

		if (mixThreadregistered && ::kha::audio2::Audio_obj::disableGcInteractions && !gcInteractionStrictlyRequired) {
			// hx::UnregisterCurrentThread();
			// mixThreadregistered = false;
		}

		if (mixThreadregistered) {
			hx::ExitGCFreeZone();
		}
#endif

		::kha::audio2::Audio_obj::_callCallback(samples, buffer->format.samples_per_second);

#ifdef KORE_MULTITHREADED_AUDIO
		if (mixThreadregistered) {
			hx::EnterGCFreeZone();
		}
#endif

		for (int i = 0; i < samples; ++i) {
			float value = ::kha::audio2::Audio_obj::_readSample();
			*(float *)&buffer->data[buffer->write_location] = value;
			buffer->write_location += 4;
			if (buffer->write_location >= buffer->data_size) {
				buffer->write_location = 0;
			}
		}
	}

	char cutCopyString[4096];

	char *copy() {
		String text = SystemImpl_obj::copy();
		if (hx::IsNull(text)) {
			return NULL;
		}
		strcpy(cutCopyString, text.c_str());
		return cutCopyString;
	}

	char *cut() {
		String text = SystemImpl_obj::cut();
		if (hx::IsNull(text)) {
			return NULL;
		}
		strcpy(cutCopyString, text.c_str());
		return cutCopyString;
	}

	void paste(char *data) {
		SystemImpl_obj::paste(String(data));
	}

	void login() {
		SystemImpl_obj::loginevent();
	}

	void logout() {
		SystemImpl_obj::logoutevent();
	}
}

void init_kinc(const char *name, int width, int height, kinc_window_options_t *win, kinc_framebuffer_options_t *frame) {
	kinc_log(KINC_LOG_LEVEL_INFO, "Starting Kinc");

	kinc_init(name, width, height, win, frame);

	kinc_mutex_init(&mutex);

	kinc_set_foreground_callback(foreground);
	kinc_set_resume_callback(resume);
	kinc_set_pause_callback(pause);
	kinc_set_background_callback(background);
	kinc_set_shutdown_callback(shutdown);
	kinc_set_drop_files_callback(dropFiles);
	kinc_set_update_callback(update);
	kinc_set_copy_callback(copy);
	kinc_set_cut_callback(cut);
	kinc_set_paste_callback(paste);
	kinc_set_login_callback(login);
	kinc_set_logout_callback(logout);

	kinc_keyboard_key_down_callback = keyDown;
	kinc_keyboard_key_up_callback = keyUp;
	kinc_keyboard_key_press_callback = keyPress;
	kinc_mouse_press_callback = mouseDown;
	kinc_mouse_release_callback = mouseUp;
	kinc_mouse_move_callback = mouseMove;
	kinc_mouse_scroll_callback = mouseWheel;
	kinc_mouse_leave_window_callback = mouseLeave;
	kinc_pen_press_callback = penDown;
	kinc_pen_release_callback = penUp;
	kinc_pen_move_callback = penMove;
	kinc_gamepad_axis_callback = gamepadAxis;
	kinc_gamepad_button_callback = gamepadButton;
	kinc_surface_touch_start_callback = touchStart;
	kinc_surface_touch_end_callback = touchEnd;
	kinc_surface_move_callback = touchMove;
	kinc_acceleration_callback = accelerometerChanged;
	kinc_rotation_callback = gyroscopeChanged;
}

const char *getGamepadId(int index) {
	return kinc_gamepad_product_name(index);
}

const char *getGamepadVendor(int index) {
	return kinc_gamepad_vendor(index);
}

void setGamepadRumble(int index, float left, float right) {
	kinc_gamepad_rumble(index, left, right);
}

void post_kinc_init() {
#ifdef VR_GEAR_VR
	// Enter VR mode
	Kore::VrInterface::Initialize();
#endif
}

void run_kinc() {
	kinc_log(KINC_LOG_LEVEL_INFO, "Starting application");
	kinc_a2_set_callback(mix);
	kinc_a2_init();
	::kha::audio2::Audio_obj::samplesPerSecond = kinc_a2_samples_per_second;
	kinc_start();
	kinc_log(KINC_LOG_LEVEL_INFO, "Application stopped");
#if !defined(KORE_XBOX_ONE) && !defined(KORE_TIZEN) && !defined(KORE_HTML5)
	kinc_threads_quit();
	kinc_stop();
#endif
}

extern "C" void kinc_memory_emergency() {
	kinc_log(KINC_LOG_LEVEL_WARNING, "Memory emergency");
	__hxcpp_collect(true);
}

extern "C" void __hxcpp_main();
extern int _hxcpp_argc;
extern char **_hxcpp_argv;

#ifdef KORE_WINDOWS
#include <Windows.h>
#endif

int kickstart(int argc, char **argv) {
	_hxcpp_argc = argc;
	_hxcpp_argv = argv;
	kinc_threads_init();
	kha_loader_init();
	HX_TOP_OF_STACK
	hx::Boot();
#ifdef NDEBUG
	try {
#endif
		__boot_all();
		__hxcpp_main();
#ifdef NDEBUG
	} catch (Dynamic e) {
		__hx_dump_stack();
		kinc_log(KINC_LOG_LEVEL_ERROR, "Error %s", e == null() ? "null" : e->toString().__CStr());
#ifdef KORE_WINDOWS
		MessageBoxW(NULL, e->toString().__WCStr(), NULL, MB_OK);
#endif
		return -1;
	}
#endif
	return 0;
}
