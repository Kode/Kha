#include <kinc/graphics4/vertexbuffer.h>
#include <kinc/graphics4/vertexstructure.h>

#include <hl.h>

extern "C" vbyte *hl_kore_create_vertexstructure(bool instanced) {
	kinc_g4_vertex_structure_t *struc = (kinc_g4_vertex_structure_t *)malloc(sizeof(kinc_g4_vertex_structure_t));
	kinc_g4_vertex_structure_init(struc);
	struc->instanced = instanced;
	return (vbyte *)struc;
}

extern "C" void hl_kore_vertexstructure_add(vbyte *structure, vbyte *name, int data) {
	kinc_g4_vertex_structure_t *struc = (kinc_g4_vertex_structure_t *)structure;
	kinc_g4_vertex_structure_add(struc, (char *)name, (kinc_g4_vertex_data_t)data);
}

extern "C" vbyte *hl_kore_create_vertexbuffer(int vertexCount, vbyte *structure, int usage, int stepRate) {
	kinc_g4_vertex_structure_t *struc = (kinc_g4_vertex_structure_t *)structure;
	kinc_g4_vertex_buffer_t *buffer = (kinc_g4_vertex_buffer_t *)malloc(sizeof(kinc_g4_vertex_buffer_t));
	kinc_g4_vertex_buffer_init(buffer, vertexCount, struc, (kinc_g4_usage_t)usage, stepRate);
	return (vbyte *)buffer;
}

extern "C" void hl_kore_delete_vertexbuffer(vbyte *buffer) {
	kinc_g4_vertex_buffer_t *buf = (kinc_g4_vertex_buffer_t *)buffer;
	kinc_g4_vertex_buffer_destroy(buf);
	free(buf);
}

extern "C" vbyte *hl_kore_vertexbuffer_lock(vbyte *buffer) {
	kinc_g4_vertex_buffer_t *buf = (kinc_g4_vertex_buffer_t *)buffer;
	return (vbyte *)kinc_g4_vertex_buffer_lock_all(buf);
}

extern "C" void hl_kore_vertexbuffer_unlock(vbyte *buffer, int count) {
	kinc_g4_vertex_buffer_t *buf = (kinc_g4_vertex_buffer_t *)buffer;
	kinc_g4_vertex_buffer_unlock_all(buf);
}

extern "C" int hl_kore_vertexbuffer_count(vbyte *buffer) {
	kinc_g4_vertex_buffer_t *buf = (kinc_g4_vertex_buffer_t *)buffer;
	return kinc_g4_vertex_buffer_count(buf);
}

extern "C" int hl_kore_vertexbuffer_stride(vbyte *buffer) {
	kinc_g4_vertex_buffer_t *buf = (kinc_g4_vertex_buffer_t *)buffer;
	return kinc_g4_vertex_buffer_stride(buf);
}
