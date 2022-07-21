#include <kinc/audio2/audio.h>
#include <kinc/graphics4/graphics.h>
#include <kinc/io/filereader.h>
#include <kinc/log.h>
#include <kinc/system.h>
#include <kinc/window.h>

#include <hl.h>

void frame();

static bool visible = true;
static bool paused = false;

typedef void (*FN_AUDIO_CALL_CALLBACK)(int);
typedef float (*FN_AUDIO_READ_SAMPLE)(void);

void (*audioCallCallback)(int);
float (*audioReadSample)(void);

static void update(void) {
	if (paused) {
		return;
	}

	kinc_a2_update();

	int windowCount = kinc_count_windows();

	for (int windowIndex = 0; windowIndex < windowCount; ++windowIndex) {
		if (visible) {
			kinc_g4_begin(windowIndex);
			frame();
			kinc_g4_end(windowIndex);
		}
	}

	if (!kinc_g4_swap_buffers()) {
		kinc_log(KINC_LOG_LEVEL_ERROR, "Graphics context lost.");
	}
}

static bool mixThreadregistered = false;

static void mix(kinc_a2_buffer_t *buffer, int samples) {
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

void hl_init_kore(vbyte *title, int width, int height, int samplesPerPixel, bool vSync, int windowMode, int windowFeatures) {
	kinc_log(KINC_LOG_LEVEL_INFO, "Starting KincHL");

	kinc_window_options_t win;
	kinc_window_options_set_defaults(&win);
	win.title = (char *)title;
	win.width = width;
	win.height = height;
	win.x = -1;
	win.y = -1;
	win.mode = (kinc_window_mode_t)windowMode;
	win.window_features = windowFeatures;
	kinc_framebuffer_options_t frame;
	kinc_framebuffer_options_set_defaults(&frame);
	frame.vertical_sync = vSync;
	frame.samples_per_pixel = samplesPerPixel;
	kinc_init((char *)title, width, height, &win, &frame);

	kinc_set_update_callback(update);
}

void hl_kinc_init_audio(vclosure *callCallback, vclosure *readSample, int *outSamplesPerSecond) {
	audioCallCallback = *((FN_AUDIO_CALL_CALLBACK *)(&callCallback->fun));
	audioReadSample = *((FN_AUDIO_READ_SAMPLE *)(&readSample->fun));
	kinc_a2_set_callback(mix);
	kinc_a2_init();
	*outSamplesPerSecond = kinc_a2_samples_per_second;
}

void hl_run_kore(void) {
	kinc_start();
}

vbyte *hl_kinc_file_contents(vbyte *name, int *size) {
	int len;
	int p = 0;
	vbyte *content;
	kinc_file_reader_t file;
	if (!kinc_file_reader_open(&file, (char *)name, KINC_FILE_TYPE_ASSET)) {
		return NULL;
	}
	hl_blocking(true);
	len = (int)kinc_file_reader_size(&file);
	if (size) {
		*size = len;
	}
	hl_blocking(false);
	content = (vbyte *)hl_gc_alloc_noptr(size ? len : len + 1);
	hl_blocking(true);
	if (!size) {
		content[len] = 0; // final 0 for UTF8
	}
	kinc_file_reader_read(&file, content, len);
	kinc_file_reader_close(&file);
	hl_blocking(false);
	return content;
}
