#include <kinc/error.h>
#include <kinc/io/filereader.h>

#define STB_VORBIS_HEADER_ONLY
#include <kinc/libs/stb_vorbis.c>

#include <hl.h>

struct WaveData {
	uint16_t audioFormat;
	uint16_t numChannels;
	uint32_t sampleRate;
	uint32_t bytesPerSecond;
	uint16_t bitsPerSample;
	uint32_t dataSize;
	uint8_t *data;
};

static void checkFOURCC(uint8_t **data, const char *fourcc, const char *filename) {
	for (int i = 0; i < 4; ++i) {
		kinc_affirm_message(*(*data) == fourcc[i], "Corrupt wav file: %s", filename);
		++(*data);
	}
}

static void readFOURCC(uint8_t **data, char *fourcc) {
	for (int i = 0; i < 4; ++i) {
		fourcc[i] = *(*data);
		++(*data);
	}
	fourcc[4] = 0;
}

static void readChunk(uint8_t **data, struct WaveData *wave) {
	char fourcc[5];
	readFOURCC(data, fourcc);
	uint32_t chunksize = kinc_read_u32le(*data);
	*data += 4;
	if (strcmp(fourcc, "fmt ") == 0) {
		wave->audioFormat = kinc_read_u16le(*data + 0);
		wave->numChannels = kinc_read_u16le(*data + 2);
		wave->sampleRate = kinc_read_u32le(*data + 4);
		wave->bytesPerSecond = kinc_read_u32le(*data + 8);
		wave->bitsPerSample = kinc_read_u16le(*data + 14);
		*data += chunksize;
	}
	else if (strcmp(fourcc, "data") == 0) {
		wave->dataSize = chunksize;
		wave->data = (uint8_t *)malloc(chunksize * sizeof(uint8_t));
		memcpy(wave->data, *data, chunksize);
		*data += chunksize;
	}
	else {
		*data += chunksize;
	}
}

static int16_t convert8to16(uint8_t sample) {
	return (sample - 128) << 8;
}

static void splitStereo8(uint8_t *data, int size, int16_t *left, int16_t *right) {
	for (int i = 0; i < size; ++i) {
		left[i] = convert8to16(data[i * 2 + 0]);
		right[i] = convert8to16(data[i * 2 + 1]);
	}
}

static void splitStereo16(int16_t *data, int size, int16_t *left, int16_t *right) {
	for (int i = 0; i < size; ++i) {
		left[i] = data[i * 2 + 0];
		right[i] = data[i * 2 + 1];
	}
}

static void splitMono8(uint8_t *data, int size, int16_t *left, int16_t *right) {
	for (int i = 0; i < size; ++i) {
		left[i] = convert8to16(data[i]);
		right[i] = convert8to16(data[i]);
	}
}

void splitMono16(int16_t *data, int size, int16_t *left, int16_t *right) {
	for (int i = 0; i < size; ++i) {
		left[i] = data[i];
		right[i] = data[i];
	}
}

vbyte *hl_kinc_sound_init_wav(vbyte *filename, vbyte *outSize, int *outSampleRate, double *outLength) {
	struct WaveData wave = {0};
	{
		kinc_file_reader_t reader;
		bool opened = kinc_file_reader_open(&reader, (char *)filename, KINC_FILE_TYPE_ASSET);
		kinc_affirm(opened);
		uint8_t *filedata = (uint8_t *)malloc(kinc_file_reader_size(&reader));
		kinc_file_reader_read(&reader, filedata, kinc_file_reader_size(&reader));
		kinc_file_reader_close(&reader);
		uint8_t *data = filedata;

		checkFOURCC(&data, "RIFF", (char *)filename);
		uint32_t filesize = kinc_read_u32le(data);
		data += 4;
		checkFOURCC(&data, "WAVE", (char *)filename);
		while (data + 8 - filedata < (intptr_t)filesize) {
			readChunk(&data, &wave);
		}

		free(filedata);
	}

	float length = (wave.dataSize / (wave.bitsPerSample / 8) / wave.numChannels) / (float)wave.sampleRate;

	int16_t *left;
	int16_t *right;

	if (wave.numChannels == 1) {
		if (wave.bitsPerSample == 8) {
			left = (int16_t *)malloc(wave.dataSize * sizeof(int16_t));
			right = (int16_t *)malloc(wave.dataSize * sizeof(int16_t));
			splitMono8(wave.data, wave.dataSize, left, right);
		}
		else if (wave.bitsPerSample == 16) {
			wave.dataSize /= 2;
			left = (int16_t *)malloc(wave.dataSize * sizeof(int16_t));
			right = (int16_t *)malloc(wave.dataSize * sizeof(int16_t));
			splitMono16((int16_t *)wave.data, wave.dataSize, left, right);
		}
		else {
			kinc_affirm(false);
		}
	}
	else {
		// Left and right channel are in s16 audio stream, alternating.
		if (wave.bitsPerSample == 8) {
			wave.dataSize /= 2;
			left = (int16_t *)malloc(wave.dataSize * sizeof(int16_t));
			right = (int16_t *)malloc(wave.dataSize * sizeof(int16_t));
			splitStereo8(wave.data, wave.dataSize, left, right);
		}
		else if (wave.bitsPerSample == 16) {
			wave.dataSize /= 4;
			left = (int16_t *)malloc(wave.dataSize * sizeof(int16_t));
			right = (int16_t *)malloc(wave.dataSize * sizeof(int16_t));
			splitStereo16((int16_t *)wave.data, wave.dataSize, left, right);
		}
		else {
			kinc_affirm(false);
		}
	}

	free(wave.data);

	float *uncompressedData = (float *)malloc(wave.dataSize * 2 * sizeof(float));
	*((unsigned int *)outSize) = wave.dataSize * 2; // Return array size to Kha
	for (uint32_t i = 0; i < wave.dataSize; i += 1) {
		uncompressedData[i * 2 + 0] = (float)(left[i] / 32767.0);
		uncompressedData[i * 2 + 1] = (float)(right[i] / 32767.0);
	}
	*outSampleRate = wave.sampleRate;
	*outLength = (double)length;

	free(left);
	free(right);

	return (vbyte *)uncompressedData;
}

vbyte *hl_kinc_sound_init_vorbis(vbyte *data, int length) {
	return (vbyte *)stb_vorbis_open_memory(data, length, NULL, NULL);
}

bool hl_kinc_sound_next_vorbis_samples(vbyte *vorbis, vbyte *samples, int length, bool loop, bool atend) {
	int read = stb_vorbis_get_samples_float_interleaved((stb_vorbis *)vorbis, 2, (float *)samples, length);
	if (read < length / 2) {
		if (loop) {
			stb_vorbis_seek_start((stb_vorbis *)vorbis);
		}
		else {
			atend = true;
		}
		for (int i = read * 2; i < length; ++i) {
			samples[i] = 0;
		}
	}
	return atend;
}

float hl_kinc_sound_vorbis_get_length(vbyte *vorbis) {
	if (vorbis == NULL) return 0;
	return stb_vorbis_stream_length_in_seconds((stb_vorbis *)vorbis);
}

float hl_kinc_sound_vorbis_get_position(vbyte *vorbis) {
	if (vorbis == NULL) return 0;
	return stb_vorbis_get_sample_offset((stb_vorbis *)vorbis) / (float)stb_vorbis_stream_length_in_samples((stb_vorbis *)vorbis);
}
