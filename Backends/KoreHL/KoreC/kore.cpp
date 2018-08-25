#include <Kore/pch.h>
#include <Kore/Log.h>
#include <Kore/System.h>
#include <Kore/Graphics4/Graphics.h>
#include <Kore/Audio2/Audio.h>
#include <Kore/Math/Random.h>

#include <hl.h>
#ifdef min
#undef min
#endif
#ifdef max
#undef max
#endif

#include <limits>

extern "C" void frame();

namespace {
	bool visible = true;
	bool paused = false;

	typedef void(*FN_AUDIO_CALL_CALLBACK)(int);
	typedef float(*FN_AUDIO_READ_SAMPLE)();

	void (*audioCallCallback)(int);
	float (*audioReadSample)();

	void update() {
		if (paused) return;
		//Kore::Audio::update();

		int windowCount = Kore::Window::count();

		for (int windowIndex = 0; windowIndex < windowCount; ++windowIndex) {
			if (visible) {
				Kore::Graphics4::begin(windowIndex);
				frame();
				Kore::Graphics4::end(windowIndex);
			}
		}

		if (!Kore::Graphics4::swapBuffers()) {
			Kore::log(Kore::Error, "Graphics context lost.");
		}
	}

	void mix(int samples) {
		using namespace Kore;

// #ifdef KORE_MULTITHREADED_AUDIO
// 		if (!mixThreadregistered) {
// 			__hxcpp_register_current_thread();
// 			mixThreadregistered = true;
// 		}
// #endif

		//audioCallCallback(samples); // TODO: HL throws "Can't lock GC in unregistered thread"

		for (int i = 0; i < samples; ++i) {
			float value = audioReadSample();
			*(float*)&Audio2::buffer.data[Audio2::buffer.writeLocation] = value;
			Audio2::buffer.writeLocation += 4;
			if (Audio2::buffer.writeLocation >= Audio2::buffer.dataSize) Audio2::buffer.writeLocation = 0;
		}
	}
}

extern "C" void hl_init_kore(vbyte *title, int width, int height, int samplesPerPixel, bool vSync, int windowMode, int windowFeatures) {
	Kore::log(Kore::Info, "Starting KoreHL");

	Kore::Random::init(static_cast<int>(Kore::System::timestamp() % std::numeric_limits<int>::max()));

	Kore::WindowOptions win;
	win.title = (char*)title;
	win.width = width;
	win.height = height;
	win.x = -1;
	win.y = -1;
	win.mode = Kore::WindowMode(windowMode);
	win.windowFeatures = windowFeatures;
	Kore::FramebufferOptions frame;
	frame.verticalSync = vSync;
	frame.samplesPerPixel = samplesPerPixel;
	Kore::System::init((char*)title, width, height, &win, &frame);

	Kore::System::setCallback(update);
}

extern "C" void hl_kore_init_audio(vclosure *callCallback, vclosure *readSample) {
	audioCallCallback = *((FN_AUDIO_CALL_CALLBACK*)(&callCallback->fun));
	audioReadSample = *((FN_AUDIO_READ_SAMPLE*)(&readSample->fun));
	Kore::Audio2::audioCallback = mix;
	Kore::Audio2::init();
}

extern "C" void run_kore() {
	Kore::System::start();
}
