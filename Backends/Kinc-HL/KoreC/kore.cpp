#include <Kore/Graphics4/Graphics.h>
#include <Kore/System.h>

#include <kinc/audio2/audio.h>
#include <kinc/log.h>

#include <hl.h>

extern "C" void frame();

namespace {
	bool visible = true;
	bool paused = false;

	typedef void (*FN_AUDIO_CALL_CALLBACK)(int);
	typedef float (*FN_AUDIO_READ_SAMPLE)();

	void (*audioCallCallback)(int);
	float (*audioReadSample)();

	void update() {
		if (paused) {
			return;
		}

		kinc_a2_update();

		int windowCount = Kore::Window::count();

		for (int windowIndex = 0; windowIndex < windowCount; ++windowIndex) {
			if (visible) {
				Kore::Graphics4::begin(windowIndex);
				frame();
				Kore::Graphics4::end(windowIndex);
			}
		}

		if (!Kore::Graphics4::swapBuffers()) {
			kinc_log(KINC_LOG_LEVEL_ERROR, "Graphics context lost.");
		}
	}

	bool mixThreadregistered = false;

	void mix(kinc_a2_buffer_t *buffer, int samples) {
		using namespace Kore;

#ifdef KORE_MULTITHREADED_AUDIO
		if (!mixThreadregistered) {
			vdynamic *ret;
			hl_register_thread(&ret);
			mixThreadregistered = true;
		}
		hl_blocking(true);
#endif

		audioCallCallback(samples);

		for (int i = 0; i < samples; ++i) {
			float value = audioReadSample();
			*(float *)&buffer->data[buffer->write_location] = value;
			buffer->write_location += 4;
			if (buffer->write_location >= buffer->data_size) {
				buffer->write_location = 0;
			}
		}

#ifdef KORE_MULTITHREADED_AUDIO
		hl_blocking(false);
#endif
	}
}

extern "C" void hl_init_kore(vbyte *title, int width, int height, int samplesPerPixel, bool vSync, int windowMode, int windowFeatures) {
	kinc_log(KINC_LOG_LEVEL_INFO, "Starting KincHL");

	Kore::WindowOptions win;
	win.title = (char *)title;
	win.width = width;
	win.height = height;
	win.x = -1;
	win.y = -1;
	win.mode = Kore::WindowMode(windowMode);
	win.windowFeatures = windowFeatures;
	Kore::FramebufferOptions frame;
	frame.verticalSync = vSync;
	frame.samplesPerPixel = samplesPerPixel;
	Kore::System::init((char *)title, width, height, &win, &frame);

	Kore::System::setCallback(update);
}

extern "C" void hl_kore_init_audio(vclosure *callCallback, vclosure *readSample, int *outSamplesPerSecond) {
	audioCallCallback = *((FN_AUDIO_CALL_CALLBACK *)(&callCallback->fun));
	audioReadSample = *((FN_AUDIO_READ_SAMPLE *)(&readSample->fun));
	kinc_a2_set_callback(mix);
	kinc_a2_init();
	*outSamplesPerSecond = kinc_a2_samples_per_second;
}

extern "C" void hl_run_kore() {
	Kore::System::start();
}

#include <Kore/IO/FileReader.h>

extern "C" vbyte *hl_kore_file_contents(vbyte *name, int *size) {
	int len;
	int p = 0;
	vbyte *content;
	Kore::FileReader file;
	if (!file.open((char *)name)) {
		return NULL;
	}
	hl_blocking(true);
	len = file.size();
	if (size) *size = len;
	hl_blocking(false);
	content = (vbyte *)hl_gc_alloc_noptr(size ? len : len + 1);
	hl_blocking(true);
	if (!size) {
		content[len] = 0; // final 0 for UTF8
	}
	file.read(content, len);
	hl_blocking(false);
	return content;
}
