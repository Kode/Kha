#pragma once

#include <kinc/threads/atomic.h>

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

struct rc_sound {
#ifdef KORE_SONY
	volatile int32_t reference_count;
#else
	volatile long reference_count;
#endif
	int16_t data[2];
};

static inline struct rc_sound *rc_floats_create(size_t count) {
	struct rc_sound *floats = (struct rc_sound *)malloc(sizeof(struct rc_sound) - sizeof(int16_t) * 2 + count * sizeof(int16_t));
	KINC_ATOMIC_EXCHANGE_32(&floats->reference_count, 1);
	return floats;
}

static inline void rc_floats_inc(struct rc_sound *floats) {
	KINC_ATOMIC_INCREMENT(&floats->reference_count);
}

static inline void rc_floats_dec(struct rc_sound *floats) {
	int value = KINC_ATOMIC_DECREMENT(&floats->reference_count);
	if (value == 1) {
		free(floats);
	}
}

#ifdef __cplusplus
}
#endif
