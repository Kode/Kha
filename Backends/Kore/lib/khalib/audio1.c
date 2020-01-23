#include "pch.h"

#include "audio1.h"

#include <kinc/audio2/audio.h>
#include <kinc/threads/mutex.h>

#include <math.h>
#include <stdlib.h>
#include <string.h>

#define CHANNEL_COUNT 32

static kinc_mutex_t mutex;

struct AudioChannel *soundChannels[CHANNEL_COUNT];

struct AudioChannel *internalSoundChannels[CHANNEL_COUNT];

static float roundf(float value) {
	return floorf(value + 0.5f);
}

static int maxi(int a, int b) {
	return a > b ? a : b;
}

static int mini(int a, int b) {
	return a < b ? a : b;
}

static float maxf(float a, float b) {
	return a > b ? a : b;
}

static float minf(float a, float b) {
	return a < b ? a : b;
}

void AudioChannel_nextSamples(struct AudioChannel *channel, float *requestedSamples, int requestedLength, int sampleRate) {
	if (channel->paused || channel->stopped) {
		for (int i = 0; i < requestedLength; ++i) {
			requestedSamples[i] = 0;
		}
		return;
	}

	int requestedSamplesIndex = 0;
	while (requestedSamplesIndex < requestedLength) {
		for (int i = 0; i < mini(channel->data_length - channel->position, requestedLength - requestedSamplesIndex); ++i) {
			requestedSamples[requestedSamplesIndex++] = channel->data[channel->position++];
		}

		if (channel->position >= channel->data_length) {
			channel->position = 0;
			if (!channel->looping) {
				channel->stopped = true;
				break;
			}
		}
	}

	while (requestedSamplesIndex < requestedLength) {
		requestedSamples[requestedSamplesIndex++] = 0;
	}
}

static void _playAgain(struct AudioChannel *channel) {
	kinc_mutex_lock(&mutex);
	for (int i = 0; i < CHANNEL_COUNT; ++i) {
		if (soundChannels[i] == channel) {
			soundChannels[i] = NULL;
		}
	}
	for (int i = 0; i < CHANNEL_COUNT; ++i) {
		if (soundChannels[i] == NULL || soundChannels[i]->finished || soundChannels[i] == channel) {
			soundChannels[i] = channel;
			break;
		}
	}
	kinc_mutex_unlock(&mutex);
}

void AudioChannel_play(struct AudioChannel *channel) {
	channel->paused = false;
	channel->stopped = false;
	_playAgain(channel);
}

void AudioChannel_pause(struct AudioChannel *channel) {
	channel->paused = true;
}

void AudioChannel_stop(struct AudioChannel *channel) {
	channel->position = 0;
	channel->stopped = true;
}

float AudioChannel_length_in_seconds(struct AudioChannel *channel) {
	return channel->data_length / (float)kinc_a2_samples_per_second / 2.0f; // Stereo
}

float AudioChannel_position_in_seconds(struct AudioChannel *channel) {
	return channel->position / (float)kinc_a2_samples_per_second / 2.0f;
}

float AudioChannel_set_position_in_seconds(struct AudioChannel *channel, float value) {
	channel->position = roundf(value * kinc_a2_samples_per_second * 2);
	channel->position = maxi(mini(channel->position, channel->data_length), 0);
	return value;
}

struct Buffer {
	int size;
	int write_location;
	int samples_per_second;
	float *data;
};

float *sampleCache1 = NULL;
float *sampleCache2 = NULL;
int sampleCacheSize = 0;

static void allocateSampleCache(int size) {
	free(sampleCache1);
	free(sampleCache2);
	sampleCacheSize = size;
	sampleCache1 = (float *)malloc(size * sizeof(float));
	sampleCache2 = (float *)malloc(size * sizeof(float));
}

static void mix(kinc_a2_buffer_t *buffer, int samples) {
	if (sampleCacheSize < samples) {
		allocateSampleCache(samples * 2);
	}

	for (int i = 0; i < samples; ++i) {
		sampleCache2[i] = 0;
	}

	kinc_mutex_lock(&mutex);
	for (int i = 0; i < CHANNEL_COUNT; ++i) {
		internalSoundChannels[i] = soundChannels[i];
	}
	kinc_mutex_unlock(&mutex);

	for (int i = 0; i < CHANNEL_COUNT; ++i) {
		struct AudioChannel *channel = internalSoundChannels[i];
		if (channel == NULL || channel->finished) continue;
		AudioChannel_nextSamples(channel, sampleCache1, samples, buffer->format.samples_per_second);
		for (int j = 0; j < samples; ++j) {
			sampleCache2[j] += sampleCache1[j] * channel->volume;
		}
	}

	// dynamicCompressor(samples, sampleCache2);

	for (int i = 0; i < samples; ++i) {
		*(float *)&buffer->data[buffer->write_location] = maxf(minf(sampleCache2[i], 1.0f), -1.0f);
		buffer->write_location += 4;
		if (buffer->write_location >= buffer->data_size) {
			buffer->write_location = 0;
		}
	}
}

void Audio_init() {
	kinc_mutex_init(&mutex);
	allocateSampleCache(512);
	memset(soundChannels, 0, sizeof(soundChannels));
	memset(internalSoundChannels, 0, sizeof(internalSoundChannels));
	kinc_a2_set_callback(mix);
}

/*static var compressedLast = false;

static function dynamicCompressor(samples : Int, cache : kha.arrays.Float32Array) {
    var sum = 0.0;
    for (i in 0...samples) {
        sum += cache[i];
    }
    sum /= samples;
    if (sum > 0.9) {
        compressedLast = true;
        for (i in 0...samples) {
            if (cache[i] > 0.9) {
                cache[i] = 0.9 + (cache[i] - 0.9) * 0.2;
            }
        }
    }
    else if (compressedLast) {
        compressedLast = false;
        for (i in 0...samples) {
            if (cache[i] > 0.9) {
                cache[i] = 0.9 + (cache[i] - 0.9) * lerp(i, samples);
            }
        }
    }
}

static inline function lerp(index : Int, samples : Int) {
    final start = 0.2;
    final end = 1.0;
    return start + (index / samples) * (end - start);
}*/

bool Audio_play(struct AudioChannel *channel, bool loop /*= false*/) {
	bool foundChannel = false;

	kinc_mutex_lock(&mutex);
	for (int i = 0; i < CHANNEL_COUNT; ++i) {
		if (soundChannels[i] == NULL || soundChannels[i]->finished) {
			soundChannels[i] = channel;
			foundChannel = true;
			break;
		}
	}
	kinc_mutex_unlock(&mutex);

	return foundChannel;
}
