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

		int windowCount = Kore::System::windowCount();

		for (int windowIndex = 0; windowIndex < windowCount; ++windowIndex) {
			if (visible) {
				Kore::Graphics4::begin(windowIndex);
				frame();
				Kore::Graphics4::end(windowIndex);
				Kore::Graphics4::swapBuffers(windowIndex);
			}
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

		audioCallCallback(samples);

		for (int i = 0; i < samples; ++i) {
			float value = audioReadSample();
			*(float*)&Audio2::buffer.data[Audio2::buffer.writeLocation] = value;
			Audio2::buffer.writeLocation += 4;
			if (Audio2::buffer.writeLocation >= Audio2::buffer.dataSize) Audio2::buffer.writeLocation = 0;
		}
	}
}

extern "C" void hl_init_kore(vbyte *title, int width, int height) {
	Kore::log(Kore::Info, "Starting Kore");

	Kore::Random::init(static_cast<int>(Kore::System::timestamp() % std::numeric_limits<int>::max()));
	Kore::System::setName((char*)title);
	Kore::System::setup();

	width = Kore::min(width, Kore::System::desktopWidth());
	height = Kore::min(height, Kore::System::desktopHeight());

	Kore::WindowOptions options;
	options.title = (char*)title;
	options.width = width;
	options.height = height;
	options.x = Kore::System::desktopWidth() / 2 - width / 2;
	options.y = Kore::System::desktopHeight() / 2 - height / 2;
	options.targetDisplay = -1;
	options.mode = Kore::WindowModeWindow;
	options.rendererOptions.depthBufferBits = 16;
	options.rendererOptions.stencilBufferBits = 8;
	options.rendererOptions.textureFormat = 0;
	options.rendererOptions.antialiasing = 1;

	Kore::System::initWindow(options);

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
