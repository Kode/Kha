#include <kinc/graphics4/rendertarget.h>
#include <kinc/graphics4/texture.h>

#include <hl.h>

vbyte *hl_kore_cubemap_create(int cubeMapSize, int depthBufferBits, int format, int stencilBufferBits, int contextId) {
	kinc_g4_render_target_t *render_target = (kinc_g4_render_target_t *)malloc(sizeof(kinc_g4_render_target_t));
	kinc_g4_render_target_init_cube(render_target, cubeMapSize, depthBufferBits, false, (kinc_g4_render_target_format_t)format, stencilBufferBits, contextId);
	return (vbyte *)render_target;
}

int hl_kore_cubemap_texture_get_width(vbyte *cubemap) {
	kinc_g4_render_target_t *cm = (kinc_g4_render_target_t *)cubemap;
	return cm->texWidth;
}

int hl_kore_cubemap_texture_get_height(vbyte *cubemap) {
	kinc_g4_render_target_t *cm = (kinc_g4_render_target_t *)cubemap;
	return cm->texHeight;
}

int hl_kore_cubemap_target_get_width(vbyte *cubemap) {
	kinc_g4_render_target_t *cm = (kinc_g4_render_target_t *)cubemap;
	return cm->width;
}

int hl_kore_cubemap_target_get_height(vbyte *cubemap) {
	kinc_g4_render_target_t *cm = (kinc_g4_render_target_t *)cubemap;
	return cm->height;
}
