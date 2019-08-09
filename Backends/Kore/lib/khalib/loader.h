#pragma once

#include <stdbool.h>
#include <stdint.h>

#include <kinc/image.h>

#ifdef __cplusplus
extern "C" {
#endif

#define KHA_MAX_PATH_LENGTH 256 - 1

typedef uint64_t kha_index_t;

typedef enum { KHA_FILE_TYPE_BLOB, KHA_FILE_TYPE_IMAGE, KHA_FILE_TYPE_SOUND } kha_file_type_t;

typedef struct {
	uint8_t *bytes;
	size_t size;
} kha_blob_t;

typedef struct {
	bool readable;
	kinc_image_t image;
} kha_image_t;

typedef struct {
	float *samples;
	uint8_t *compressed_samples;
	size_t size;
	size_t channels;
	int sample_rate;
	float length;
} kha_sound_t;

typedef union {
	kha_blob_t blob;
	kha_image_t image;
	kha_sound_t sound;
} kha_file_data_t;

typedef struct {
	char name[KHA_MAX_PATH_LENGTH + 1];
	kha_file_type_t type;
	kha_file_data_t data;
	kha_index_t index;
	bool error;
} kha_file_reference_t;

void kha_loader_init();
kha_index_t kha_loader_load_blob(const char *filename);
kha_index_t kha_loader_load_image(const char *filename, bool readable);
kha_index_t kha_loader_load_sound(const char *filename);
kha_file_reference_t kha_loader_get_file();

#ifdef __cplusplus
}
#endif
