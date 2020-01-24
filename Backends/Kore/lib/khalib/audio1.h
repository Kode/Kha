#pragma once

#include "rcfloats.h"

#ifdef __cplusplus
extern "C" {
#endif

struct AudioChannel {
	volatile int position;
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

#ifdef __cplusplus
}
#endif
