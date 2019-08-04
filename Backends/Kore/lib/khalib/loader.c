#include "pch.h"

#include "loader.h"

#include <kinc/audio1/sound.h>
#include <kinc/image.h>
#include <kinc/io/filereader.h>
#include <kinc/threads/event.h>
#include <kinc/threads/mutex.h>
#include <kinc/threads/thread.h>

#define STB_DS_IMPLEMENTATION
#include "stb_ds.h"

#include <assert.h>

static kinc_thread_t thread;
static kinc_event_t event;
static kinc_mutex_t loading_mutex;
static kinc_mutex_t loaded_mutex;

static kha_index_t next_index = 1;

static kha_file_reference_t *loading_files = NULL;
static kha_file_reference_t *loaded_files = NULL;

static bool string_ends_with(char *str, char *end) {
	size_t str_len = strlen(str);
	size_t end_len = strlen(end);
	if (end_len > str_len) {
		return false;
	}
	return strcmp(&str[str_len - end_len], end) == 0;
}

static void run(void* param) {
	for (;;) {
		kinc_event_wait(&event);

		bool has_next = false;
		kha_file_reference_t next;

		kinc_mutex_lock(&loading_mutex);
		if (arrlen(loading_files) > 0) {
			has_next = true;
			next = arrpop(loading_files);
		}
		else {
			kinc_event_reset(&event);
		}
		kinc_mutex_unlock(&loading_mutex);

		while (has_next) {
			switch (next.type) {
			case KHA_FILE_TYPE_BLOB: {
				kinc_file_reader_t reader;
				if (kinc_file_reader_open(&reader, next.name, KINC_FILE_TYPE_ASSET)) {
					next.data.blob.size = kinc_file_reader_size(&reader);
					next.data.blob.bytes = malloc(next.data.blob.size);
					kinc_file_reader_read(&reader, next.data.blob.bytes, next.data.blob.size);
					kinc_file_reader_close(&reader);
				}
				else {
					next.error = true;
				}
				break;
			}
			case KHA_FILE_TYPE_IMAGE: {
				kinc_image_t image;
				size_t size = kinc_image_size_from_file(next.name);
				void *data = malloc(size);
				if (kinc_image_init_from_file(&image, data, next.name) != 0) {
					next.data.image.image = image;
				}
				else {
					free(data);
					next.error = true;
				}
				break;
			}
			case KHA_FILE_TYPE_SOUND: {
				memset(&next.data.sound, 0, sizeof(next.data.sound));
				if (string_ends_with(next.name, ".ogg")) {
					kinc_file_reader_t reader;
					if (kinc_file_reader_open(&reader, next.name, KINC_FILE_TYPE_ASSET)) {
						next.data.sound.size = kinc_file_reader_size(&reader);
						next.data.sound.compressed_samples = (uint8_t *)malloc(next.data.sound.size);
						kinc_file_reader_read(&reader, next.data.sound.compressed_samples, kinc_file_reader_size(&reader));
						kinc_file_reader_close(&reader);
					}
					else {
						next.error = true;
					}
				}
				else {
					kinc_a1_sound_t *sound = kinc_a1_sound_create(next.name);
					next.data.sound.size = sound->size * 2;
					next.data.sound.samples = (float *)malloc(next.data.sound.size * sizeof(float));
					for (int i = 0; i < sound->size; ++i) {
						next.data.sound.samples[i * 2 + 0] = (float)(sound->left[i] / 32767.0);
						next.data.sound.samples[i * 2 + 1] = (float)(sound->right[i] / 32767.0);
					}
					next.data.sound.channels = sound->format.channels;
					next.data.sound.length = (sound->size / (sound->format.bits_per_sample / 8) / sound->format.channels) / (float)sound->format.samples_per_second;
				}
				break;
			}
			}

			kinc_mutex_lock(&loaded_mutex);
			arrput(loaded_files, next);
			kinc_mutex_unlock(&loaded_mutex);

			has_next = false;
			kinc_mutex_lock(&loading_mutex);
			if (arrlen(loading_files) > 0) {
				has_next = true;
				next = arrpop(loading_files);
			}
			else {
				kinc_event_reset(&event);
			}
			kinc_mutex_unlock(&loading_mutex);
		}
	}
}

void kha_loader_init() {
	kinc_mutex_init(&loaded_mutex);
	kinc_mutex_init(&loading_mutex);
	kinc_event_init(&event);
	kinc_thread_init(&thread, run, NULL);
}

kha_index_t kha_loader_load_blob(const char *filename) {
	assert(strlen(filename) <= KHA_MAX_PATH_LENGTH);
	kha_file_reference_t file;
	memset(&file, 0, sizeof(file));
	file.index = next_index++;
	strcpy(file.name, filename);
	file.type = KHA_FILE_TYPE_BLOB;

	kinc_mutex_lock(&loading_mutex);
	arrput(loading_files, file);
	kinc_event_signal(&event);
	kinc_mutex_unlock(&loading_mutex);

	return file.index;
}

kha_index_t kha_loader_load_image(const char *filename, bool readable) {
	assert(strlen(filename) <= KHA_MAX_PATH_LENGTH);
	kha_file_reference_t file;
	memset(&file, 0, sizeof(file));
	file.index = next_index++;
	strcpy(file.name, filename);
	file.type = KHA_FILE_TYPE_IMAGE;
	file.data.image.readable = readable;

	kinc_mutex_lock(&loading_mutex);
	arrput(loading_files, file);
	kinc_event_signal(&event);
	kinc_mutex_unlock(&loading_mutex);

	return file.index;
}

kha_index_t kha_loader_load_sound(const char *filename) {
	assert(strlen(filename) <= KHA_MAX_PATH_LENGTH);
	kha_file_reference_t file;
	memset(&file, 0, sizeof(file));
	file.index = next_index++;
	strcpy(file.name, filename);
	file.type = KHA_FILE_TYPE_SOUND;

	kinc_mutex_lock(&loading_mutex);
	arrput(loading_files, file);
	kinc_event_signal(&event);
	kinc_mutex_unlock(&loading_mutex);

	return file.index;
}

kha_file_reference_t kha_loader_get_file() {
	kinc_mutex_lock(&loaded_mutex);
	if (arrlen(loaded_files) > 0) {
		kha_file_reference_t file = arrpop(loaded_files);
		kinc_mutex_unlock(&loaded_mutex);
		return file;
	}
	else {
		kinc_mutex_unlock(&loaded_mutex);
		kha_file_reference_t file;
		memset(&file, 0, sizeof(file));
		return file;
	}
}
