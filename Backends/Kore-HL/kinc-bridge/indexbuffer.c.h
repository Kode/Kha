#include <kinc/graphics4/indexbuffer.h>

#include <hl.h>

vbyte *hl_kinc_create_indexbuffer(int count) {
	kinc_g4_index_buffer_t *buffer = (kinc_g4_index_buffer_t *)malloc(sizeof(kinc_g4_index_buffer_t));
	kinc_g4_index_buffer_init(buffer, count, KINC_G4_INDEX_BUFFER_FORMAT_32BIT, KINC_G4_USAGE_STATIC);
	return (vbyte *)buffer;
}

void hl_kinc_delete_indexbuffer(vbyte *buffer) {
	kinc_g4_index_buffer_t *buf = (kinc_g4_index_buffer_t *)buffer;
	kinc_g4_index_buffer_destroy(buf);
	free(buf);
}

vbyte *hl_kinc_indexbuffer_lock(vbyte *buffer, int start, int count) {
	kinc_g4_index_buffer_t *buf = (kinc_g4_index_buffer_t *)buffer;
	return (vbyte *)kinc_g4_index_buffer_lock(buf, start, count);
}

void hl_kinc_indexbuffer_unlock(vbyte *buffer, int count) {
	kinc_g4_index_buffer_t *buf = (kinc_g4_index_buffer_t *)buffer;
	kinc_g4_index_buffer_unlock(buf, count);
}
