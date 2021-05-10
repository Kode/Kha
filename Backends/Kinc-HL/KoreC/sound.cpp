#include <Kore/Audio1/Sound.h>
#include <hl.h>

#define STB_VORBIS_HEADER_ONLY
#include <kinc/audio1/stb_vorbis.c>

extern "C" vbyte *hl_kore_sound_init_wav(vbyte* filename, vbyte* outSize, float* outLength) {
	Kore::Sound* sound = new Kore::Sound((char*)filename);
	float* uncompressedData = new float[sound->size * 2];
	reinterpret_cast<unsigned int*>(outSize)[0] = sound->size * 2; // Return array size to Kha
	Kore::s16* left = (Kore::s16*)&sound->left[0];
	Kore::s16* right = (Kore::s16*)&sound->right[0];
	for (int i = 0; i < sound->size; i += 1) {
		uncompressedData[i * 2 + 0] = (float)(left [i] / 32767.0);
		uncompressedData[i * 2 + 1] = (float)(right[i] / 32767.0);
	}
	*outLength = sound->length;
	delete sound;
	return (vbyte*)uncompressedData;
}

extern "C" vbyte *hl_kore_sound_init_vorbis(vbyte* data, int length) {
	return (vbyte*)stb_vorbis_open_memory(data, length, NULL, NULL);
}

extern "C" bool hl_kore_sound_next_vorbis_samples(vbyte* vorbis, vbyte* samples, int length, bool loop, bool atend) {
	int read = stb_vorbis_get_samples_float_interleaved((stb_vorbis*)vorbis, 2, (float*)samples, length);
	if (read < length / 2) {
		if (loop) {
			stb_vorbis_seek_start((stb_vorbis*)vorbis);
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

extern "C" float hl_kore_sound_vorbis_get_length(vbyte* vorbis) {
	if (vorbis == NULL) return 0;
	return stb_vorbis_stream_length_in_seconds((stb_vorbis*)vorbis);
}

extern "C" float hl_kore_sound_vorbis_get_position(vbyte* vorbis) {
	if (vorbis == NULL) return 0;
	return stb_vorbis_get_sample_offset((stb_vorbis*)vorbis) / stb_vorbis_stream_length_in_samples((stb_vorbis*)vorbis);
}
