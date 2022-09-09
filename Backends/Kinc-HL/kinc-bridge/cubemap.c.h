#include <kinc/graphics4/rendertarget.h>
#include <kinc/graphics4/texture.h>

#include <hl.h>

vbyte *hl_kinc_cubemap_create(int cubeMapSize, int depthBufferBits, int format, int stencilBufferBits) {
	kinc_g4_render_target_t *render_target = (kinc_g4_render_target_t *)malloc(sizeof(kinc_g4_render_target_t));
	kinc_g4_render_target_init_cube(render_target, cubeMapSize, (kinc_g4_render_target_format_t)format, depthBufferBits, stencilBufferBits);
	return (vbyte *)render_target;
}

int hl_kinc_cubemap_texture_get_width(vbyte *cubemap) {
	kinc_g4_render_target_t *cm = (kinc_g4_render_target_t *)cubemap;
	return cm->texWidth;
}

int hl_kinc_cubemap_texture_get_height(vbyte *cubemap) {
	kinc_g4_render_target_t *cm = (kinc_g4_render_target_t *)cubemap;
	return cm->texHeight;
}

int hl_kinc_cubemap_target_get_width(vbyte *cubemap) {
	kinc_g4_render_target_t *cm = (kinc_g4_render_target_t *)cubemap;
	return cm->width;
}

int hl_kinc_cubemap_target_get_height(vbyte *cubemap) {
	kinc_g4_render_target_t *cm = (kinc_g4_render_target_t *)cubemap;
	return cm->height;
}
