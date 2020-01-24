#pragma once

#include <kinc/threads/atomic.h>

#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

struct rc_floats {
	volatile long reference_count;
	float floats[1];
};

static struct rc_floats *rc_floats_create(size_t count) {
	struct rc_floats *floats = (struct rc_floats *)malloc(sizeof(struct rc_floats) - sizeof(float) + count * sizeof(float));
	KINC_ATOMIC_EXCHANGE_32(&floats->reference_count, 1);
	return floats;
}

static void rc_floats_inc(struct rc_floats *floats) {
	KINC_ATOMIC_INCREMENT(&floats->reference_count);
}

static void rc_floats_dec(struct rc_floats *floats) {
	int value = KINC_ATOMIC_DECREMENT(&floats->reference_count);
	if (value == 1) {
		free(floats);
	}
}

#ifdef __cplusplus
}
#endif
