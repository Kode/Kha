#include <kinc/graphics4/compute.h>
#include <kinc/graphics4/texture.h>

#include <hl.h>

vbyte *hl_kinc_g4_compute_create_shader(vbyte *data, int length) {
	kinc_g4_compute_shader *shader = (kinc_g4_compute_shader *)malloc(sizeof(kinc_g4_compute_shader));
	kinc_g4_compute_shader_init(shader, data, length);
	return (vbyte *)shader;
}

void hl_kinc_g4_compute_delete_shader(vbyte *shader) {
	kinc_g4_compute_shader *sh = (kinc_g4_compute_shader *)shader;
	kinc_g4_compute_shader_destroy(sh);
	free(sh);
}

vbyte *hl_kinc_g4_compute_get_constantlocation(vbyte *shader, vbyte *name) {
	kinc_g4_compute_shader *sh = (kinc_g4_compute_shader *)shader;
	kinc_g4_constant_location_t *location = (kinc_g4_constant_location_t *)malloc(sizeof(kinc_g4_constant_location_t));
	*location = kinc_g4_compute_shader_get_constant_location(sh, (char *)name), sizeof(kinc_g4_constant_location_t);
	return (vbyte *)location;
}

vbyte *hl_kinc_g4_compute_get_textureunit(vbyte *shader, vbyte *name) {
	kinc_g4_compute_shader *sh = (kinc_g4_compute_shader *)shader;
	kinc_g4_texture_unit_t *unit = (kinc_g4_texture_unit_t *)malloc(sizeof(kinc_g4_texture_unit_t));
	*unit = kinc_g4_compute_shader_get_texture_unit(sh, (char *)name), sizeof(kinc_g4_texture_unit_t);
	return (vbyte *)unit;
}

void hl_kinc_g4_set_compute_shader(vbyte *shader) {
	kinc_g4_set_compute_shader((kinc_g4_compute_shader *)shader);
}

void hl_kinc_g4_compute(int x, int y, int z) {
	kinc_g4_compute(x, y, z);
}
