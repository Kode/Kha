#pragma once

#ifdef __cplusplus
extern "C" {
#endif

struct AudioChannel {
	bool finished;
	float volume;
	float *data;
	int data_length;
	int position;
	bool paused;
	bool stopped;
	bool looping;
};

void Audio_init();
bool Audio_play(struct AudioChannel *channel, bool loop);

#ifdef __cplusplus
}
#endif
