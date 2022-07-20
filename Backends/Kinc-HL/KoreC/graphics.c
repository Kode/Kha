#include <kinc/graphics4/graphics.h>
#include <kinc/graphics4/indexbuffer.h>
#include <kinc/graphics4/texturearray.h>
#include <kinc/graphics4/vertexbuffer.h>

#include <hl.h>

#include <assert.h>

void hl_kore_graphics_clear(int flags, int color, float z, int stencil) {
	kinc_g4_clear(flags, color, z, stencil);
}

bool hl_kore_graphics_vsynced(void) {
	return true; // Kore::Graphics4::vsynced();
}

int hl_kore_graphics_refreshrate(void) {
	return 60; // Kore::Graphics4::refreshRate();
}

void hl_kore_graphics_viewport(int x, int y, int width, int height) {
	kinc_g4_viewport(x, y, width, height);
}

void hl_kore_graphics_set_vertexbuffer(vbyte *buffer) {
	kinc_g4_vertex_buffer_t *buf = (kinc_g4_vertex_buffer_t *)buffer;
	kinc_g4_set_vertex_buffer(buf);
}

void hl_kore_graphics_set_vertexbuffers(vbyte *b0, vbyte *b1, vbyte *b2, vbyte *b3, int count) {
	assert(count <= 4);
	kinc_g4_vertex_buffer_t *vertexBuffers[4] = {(kinc_g4_vertex_buffer_t *)b0, (kinc_g4_vertex_buffer_t *)b1, (kinc_g4_vertex_buffer_t *)b2,
	                                             (kinc_g4_vertex_buffer_t *)b3};
	kinc_g4_set_vertex_buffers(vertexBuffers, count);
}

void hl_kore_graphics_set_indexbuffer(vbyte *buffer) {
	kinc_g4_index_buffer_t *buf = (kinc_g4_index_buffer_t *)buffer;
	kinc_g4_set_index_buffer(buf);
}

void hl_kore_graphics_scissor(int x, int y, int width, int height) {
	kinc_g4_scissor(x, y, width, height);
}

void hl_kore_graphics_disable_scissor(void) {
	kinc_g4_disable_scissor();
}

bool hl_kore_graphics_render_targets_inverted_y(void) {
	return kinc_g4_render_targets_inverted_y();
}

void hl_kore_graphics_set_texture_parameters(vbyte *unit, int uAddressing, int vAddressing, int minificationFilter, int magnificationFilter, int mipmapFilter) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_set_texture_addressing(*u, KINC_G4_TEXTURE_DIRECTION_U, (kinc_g4_texture_addressing_t)uAddressing);
	kinc_g4_set_texture_addressing(*u, KINC_G4_TEXTURE_DIRECTION_V, (kinc_g4_texture_addressing_t)vAddressing);
	kinc_g4_set_texture_minification_filter(*u, (kinc_g4_texture_filter_t)minificationFilter);
	kinc_g4_set_texture_magnification_filter(*u, (kinc_g4_texture_filter_t)magnificationFilter);
	kinc_g4_set_texture_mipmap_filter(*u, (kinc_g4_mipmap_filter_t)mipmapFilter);
}

void hl_kore_graphics_set_texture3d_parameters(vbyte *unit, int uAddressing, int vAddressing, int wAddressing, int minificationFilter, int magnificationFilter,
                                               int mipmapFilter) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_set_texture3d_addressing(*u, KINC_G4_TEXTURE_DIRECTION_U, (kinc_g4_texture_addressing_t)uAddressing);
	kinc_g4_set_texture3d_addressing(*u, KINC_G4_TEXTURE_DIRECTION_V, (kinc_g4_texture_addressing_t)vAddressing);
	kinc_g4_set_texture3d_addressing(*u, KINC_G4_TEXTURE_DIRECTION_W, (kinc_g4_texture_addressing_t)wAddressing);
	kinc_g4_set_texture3d_minification_filter(*u, (kinc_g4_texture_filter_t)minificationFilter);
	kinc_g4_set_texture3d_magnification_filter(*u, (kinc_g4_texture_filter_t)magnificationFilter);
	kinc_g4_set_texture3d_mipmap_filter(*u, (kinc_g4_mipmap_filter_t)mipmapFilter);
}

void hl_kore_graphics_set_texture_compare_mode(vbyte *unit, bool enabled) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_set_texture_compare_mode(*u, enabled);
}

void hl_kore_graphics_set_cube_map_compare_mode(vbyte *unit, bool enabled) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_set_cubemap_compare_mode(*u, enabled);
}

void hl_kore_graphics_set_texture(vbyte *unit, vbyte *texture) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_texture_t *tex = (kinc_g4_texture_t *)texture;
	kinc_g4_set_texture(*u, tex);
}

void hl_kore_graphics_set_texture_depth(vbyte *unit, vbyte *renderTarget) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_render_target_use_depth_as_texture(rt, *u);
}

void hl_kore_graphics_set_texture_array(vbyte *unit, vbyte *textureArray) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_texture_array_t *texArray = (kinc_g4_texture_array_t *)textureArray;
	kinc_g4_set_texture_array(*u, texArray);
}

void hl_kore_graphics_set_render_target(vbyte *unit, vbyte *renderTarget) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_render_target_use_color_as_texture(rt, *u);
}

void hl_kore_graphics_set_cubemap_texture(vbyte *unit, vbyte *renderTarget) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_render_target_use_color_as_texture(rt, *u);
}

void hl_kore_graphics_set_cubemap_depth(vbyte *unit, vbyte *renderTarget) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_render_target_use_depth_as_texture(rt, *u);
}

void hl_kore_graphics_set_image_texture(vbyte *unit, vbyte *texture) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_texture_t *tex = (kinc_g4_texture_t *)texture;
	kinc_g4_set_image_texture(*u, tex);
}

void hl_kore_graphics_set_cubemap_target(vbyte *unit, vbyte *renderTarget) {
	kinc_g4_texture_unit_t *u = (kinc_g4_texture_unit_t *)unit;
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_render_target_use_color_as_texture(rt, *u);
}

void hl_kore_graphics_set_bool(vbyte *location, bool value) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_bool(*loc, value);
}

void hl_kore_graphics_set_int(vbyte *location, int value) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_int(*loc, value);
}

void hl_kore_graphics_set_int2(vbyte *location, int value1, int value2) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_int2(*loc, value1, value2);
}

void hl_kore_graphics_set_int3(vbyte *location, int value1, int value2, int value3) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_int3(*loc, value1, value2, value3);
}

void hl_kore_graphics_set_int4(vbyte *location, int value1, int value2, int value3, int value4) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_int4(*loc, value1, value2, value3, value4);
}

void hl_kore_graphics_set_ints(vbyte *location, vbyte *values, int count) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_ints(*loc, (int *)values, count);
}

void hl_kore_graphics_set_float(vbyte *location, float value) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_float(*loc, value);
}

void hl_kore_graphics_set_float2(vbyte *location, float value1, float value2) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_float2(*loc, value1, value2);
}

void hl_kore_graphics_set_float3(vbyte *location, float value1, float value2, float value3) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_float3(*loc, value1, value2, value3);
}

void hl_kore_graphics_set_float4(vbyte *location, float value1, float value2, float value3, float value4) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_float4(*loc, value1, value2, value3, value4);
}

void hl_kore_graphics_set_floats(vbyte *location, vbyte *values, int count) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_g4_set_floats(*loc, (float *)values, count);
}

void hl_kore_graphics_set_matrix(vbyte *location, float _00, float _10, float _20, float _30, float _01, float _11, float _21, float _31, float _02, float _12,
                                 float _22, float _32, float _03, float _13, float _23, float _33) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_matrix4x4_t value;
	kinc_matrix4x4_set(&value, 0, 0, _00);
	kinc_matrix4x4_set(&value, 1, 0, _01);
	kinc_matrix4x4_set(&value, 2, 0, _02);
	kinc_matrix4x4_set(&value, 3, 0, _03);
	kinc_matrix4x4_set(&value, 0, 1, _10);
	kinc_matrix4x4_set(&value, 1, 1, _11);
	kinc_matrix4x4_set(&value, 2, 1, _12);
	kinc_matrix4x4_set(&value, 3, 1, _13);
	kinc_matrix4x4_set(&value, 0, 2, _20);
	kinc_matrix4x4_set(&value, 1, 2, _21);
	kinc_matrix4x4_set(&value, 2, 2, _22);
	kinc_matrix4x4_set(&value, 3, 2, _23);
	kinc_matrix4x4_set(&value, 0, 3, _30);
	kinc_matrix4x4_set(&value, 1, 3, _31);
	kinc_matrix4x4_set(&value, 2, 3, _32);
	kinc_matrix4x4_set(&value, 3, 3, _33);
	kinc_g4_set_matrix4(*loc, &value);
}

void hl_kore_graphics_set_matrix3(vbyte *location, float _00, float _10, float _20, float _01, float _11, float _21, float _02, float _12, float _22) {
	kinc_g4_constant_location_t *loc = (kinc_g4_constant_location_t *)location;
	kinc_matrix3x3_t value;
	kinc_matrix3x3_set(&value, 0, 0, _00);
	kinc_matrix3x3_set(&value, 1, 0, _01);
	kinc_matrix3x3_set(&value, 2, 0, _02);
	kinc_matrix3x3_set(&value, 0, 1, _10);
	kinc_matrix3x3_set(&value, 1, 1, _11);
	kinc_matrix3x3_set(&value, 2, 1, _12);
	kinc_matrix3x3_set(&value, 0, 2, _20);
	kinc_matrix3x3_set(&value, 1, 2, _21);
	kinc_matrix3x3_set(&value, 2, 2, _22);
	kinc_g4_set_matrix3(*loc, &value);
}

void hl_kore_graphics_draw_all_indexed_vertices(void) {
	kinc_g4_draw_indexed_vertices();
}

void hl_kore_graphics_draw_indexed_vertices(int start, int count) {
	kinc_g4_draw_indexed_vertices_from_to(start, count);
}

void hl_kore_graphics_draw_all_indexed_vertices_instanced(int instanceCount) {
	kinc_g4_draw_indexed_vertices_instanced(instanceCount);
}

void hl_kore_graphics_draw_indexed_vertices_instanced(int instanceCount, int start, int count) {
	kinc_g4_draw_indexed_vertices_instanced_from_to(instanceCount, start, count);
}

void hl_kore_graphics_restore_render_target(void) {
	kinc_g4_restore_render_target();
}

void hl_kore_graphics_render_to_texture(vbyte *renderTarget) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_set_render_targets(&rt, 1);
}

void hl_kore_graphics_render_to_textures(vbyte *rt0, vbyte *rt1, vbyte *rt2, vbyte *rt3, vbyte *rt4, vbyte *rt5, vbyte *rt6, vbyte *rt7, int count) {
	assert(count <= 8);
	kinc_g4_render_target_t *t0 = (kinc_g4_render_target_t *)rt0;
	kinc_g4_render_target_t *t1 = (kinc_g4_render_target_t *)rt1;
	kinc_g4_render_target_t *t2 = (kinc_g4_render_target_t *)rt2;
	kinc_g4_render_target_t *t3 = (kinc_g4_render_target_t *)rt3;
	kinc_g4_render_target_t *t4 = (kinc_g4_render_target_t *)rt4;
	kinc_g4_render_target_t *t5 = (kinc_g4_render_target_t *)rt5;
	kinc_g4_render_target_t *t6 = (kinc_g4_render_target_t *)rt6;
	kinc_g4_render_target_t *t7 = (kinc_g4_render_target_t *)&rt7;
	kinc_g4_render_target_t *targets[8] = {t0, t1, t2, t3, t4, t5, t6, t7};
	kinc_g4_set_render_targets(targets, count);
}

void hl_kore_graphics_render_to_face(vbyte *renderTarget, int face) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_set_render_target_face(rt, face);
}

void hl_kore_graphics_flush(void) {
	kinc_g4_flush();
}
