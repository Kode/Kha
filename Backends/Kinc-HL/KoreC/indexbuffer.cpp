#include <kinc/graphics4/indexbuffer.h>

#include <hl.h>

extern "C" vbyte *hl_kore_create_indexbuffer(int count) {
	kinc_g4_index_buffer_t *buffer = (kinc_g4_index_buffer_t *)malloc(sizeof(kinc_g4_index_buffer_t));
	kinc_g4_index_buffer_init(buffer, count, KINC_G4_INDEX_BUFFER_FORMAT_32BIT, KINC_G4_USAGE_STATIC);
	return (vbyte *)buffer;
}

extern "C" void hl_kore_delete_indexbuffer(vbyte *buffer) {
	kinc_g4_index_buffer_t *buf = (kinc_g4_index_buffer_t *)buffer;
	kinc_g4_index_buffer_destroy(buf);
	free(buf);
}

extern "C" vbyte *hl_kore_indexbuffer_lock(vbyte *buffer) {
	kinc_g4_index_buffer_t *buf = (kinc_g4_index_buffer_t *)buffer;
	return (vbyte *)kinc_g4_index_buffer_lock(buf);
}

extern "C" void hl_kore_indexbuffer_unlock(vbyte *buffer) {
	kinc_g4_index_buffer_t *buf = (kinc_g4_index_buffer_t *)buffer;
	kinc_g4_index_buffer_unlock(buf);
}
