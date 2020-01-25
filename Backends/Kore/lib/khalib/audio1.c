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

static float round_float(float value) {
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

/*void AudioChannel_nextSamples(struct AudioChannel *channel, float *requestedSamples, int requestedLength, int sampleRate) {
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
}*/

static int sampleLength(struct AudioChannel *channel, int sampleRate) {
	int value = (int)ceilf((float)channel->data_length * ((float)sampleRate / (float)channel->sample_rate));
	return value % 2 == 0 ? value : value + 1;
}

static float lerp(float v0, float v1, float t) {
	return (1.0f - t) * v0 + t * v1;
}

static float sample(struct AudioChannel *channel, int position, int sampleRate) {
	bool even = position % 2 == 0;
	float factor = (float)channel->sample_rate / (float)sampleRate;

	if (even) {
		position /= 2;
		float pos = factor * position;
		int pos1 = (int)floorf(pos);
		int pos2 = pos1 + 1;
		pos1 *= 2;
		pos2 *= 2;

		int minimum = 0;
		int maximum = channel->data_length - 1;
		maximum = maximum % 2 == 0 ? maximum : maximum - 1;

		float a = (pos1 < minimum || pos1 > maximum) ? 0 : channel->data->floats[pos1];
		float b = (pos2 < minimum || pos2 > maximum) ? 0 : channel->data->floats[pos2];
		return lerp(a, b, pos - floorf(pos));
	}
	else {
		position /= 2;
		float pos = factor * position;
		int pos1 = (int)floorf(pos);
		int pos2 = pos1 + 1;
		pos1 = pos1 * 2 + 1;
		pos2 = pos2 * 2 + 1;

		int minimum = 1;
		int maximum = channel->data_length - 1;
		maximum = maximum % 2 != 0 ? maximum : maximum - 1;

		float a = (pos1 < minimum || pos1 > maximum) ? 0 : channel->data->floats[pos1];
		float b = (pos2 < minimum || pos2 > maximum) ? 0 : channel->data->floats[pos2];
		return lerp(a, b, pos - floorf(pos));
	}
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
		for (int i = 0; i < mini(sampleLength(channel, sampleRate) - channel->position, requestedLength - requestedSamplesIndex); ++i) {
			requestedSamples[requestedSamplesIndex++] = sample(channel, channel->position++, sampleRate);
		}

		if (channel->position >= sampleLength(channel, sampleRate)) {
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

void AudioChannel_playAgain(struct AudioChannel *channel) {
	kinc_mutex_lock(&mutex);
	int i;
	for (i = 0; i < CHANNEL_COUNT; ++i) {
		if (soundChannels[i] == NULL) {
			AudioChannel_inc(channel);
			soundChannels[i] = channel;
			break;
		}
		if (soundChannels[i] == channel) {
			break;
		}
		if (soundChannels[i]->stopped) {
			AudioChannel_dec(soundChannels[i]);
			AudioChannel_inc(channel);
			soundChannels[i] = channel;
			break;
		}
	}
	++i;
	for (; i < CHANNEL_COUNT; ++i) {
		if (soundChannels[i] == channel) {
			AudioChannel_dec(soundChannels[i]);
			soundChannels[i] = NULL;
		}
	}
	kinc_mutex_unlock(&mutex);
}

void AudioChannel_play(struct AudioChannel *channel) {
	channel->paused = false;
	channel->stopped = false;
	AudioChannel_playAgain(channel);
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
	channel->position = (int)round_float(value * kinc_a2_samples_per_second * 2);
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
		if (soundChannels[i] != NULL) {
			AudioChannel_inc(soundChannels[i]);
		}
		internalSoundChannels[i] = soundChannels[i];
	}
	kinc_mutex_unlock(&mutex);

	for (int i = 0; i < CHANNEL_COUNT; ++i) {
		struct AudioChannel *channel = internalSoundChannels[i];
		if (channel == NULL || channel->paused || channel->stopped) continue;
		AudioChannel_nextSamples(channel, sampleCache1, samples, kinc_a2_samples_per_second);
		for (int j = 0; j < samples; ++j) {
			sampleCache2[j] += sampleCache1[j] * channel->volume;
		}
	}

	for (int i = 0; i < CHANNEL_COUNT; ++i) {
		if (internalSoundChannels[i] != NULL) {
			AudioChannel_dec(internalSoundChannels[i]);
			internalSoundChannels[i] = NULL;
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
		if (soundChannels[i] == NULL || soundChannels[i]->stopped) {
			if (soundChannels[i] != NULL) {
				AudioChannel_dec(soundChannels[i]);
			}
			AudioChannel_inc(channel);
			soundChannels[i] = channel;
			foundChannel = true;
			break;
		}
	}
	kinc_mutex_unlock(&mutex);

	return foundChannel;
}
