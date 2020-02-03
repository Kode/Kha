#pragma once

#include "rcfloats.h"

#ifdef __cplusplus
extern "C" {
#endif

struct AudioChannel {
#ifdef KORE_SONY
	volatile int32_t reference_count;
	volatile int32_t position;
#else
	volatile long reference_count;
	volatile long position;
#endif
	volatile float volume;
	volatile bool paused;
	volatile bool stopped;
	struct rc_floats *data;
	int data_length;
	bool looping;
	int sample_rate;
};

void Audio_init();
bool Audio_play(struct AudioChannel *channel, bool loop);
void AudioChannel_playAgain(struct AudioChannel *channel);

static struct AudioChannel *AudioChannel_create(struct rc_floats *floats) {
	rc_floats_inc(floats);
	struct AudioChannel *channel = (struct AudioChannel *)malloc(sizeof(struct AudioChannel));
	channel->data = floats;
	KINC_ATOMIC_EXCHANGE_32(&channel->reference_count, 1);
	return channel;
}

static void AudioChannel_inc(struct AudioChannel *channel) {
	KINC_ATOMIC_INCREMENT(&channel->reference_count);
}

static void AudioChannel_dec(struct AudioChannel *channel) {
	int value = KINC_ATOMIC_DECREMENT(&channel->reference_count);
	if (value == 1) {
		rc_floats_dec(channel->data);
		free(channel);
	}
}

#ifdef __cplusplus
}
#endif
