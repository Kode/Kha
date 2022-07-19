#include <kinc/compute/compute.h>
#include <kinc/graphics4/texture.h>

#include <Kore/Graphics4/Graphics.h>

#include <hl.h>

extern "C" vbyte *hl_kore_compute_create_shader(vbyte *data, int length) {
	kinc_compute_shader_t *shader = (kinc_compute_shader_t *)malloc(sizeof(kinc_compute_shader_t));
	kinc_compute_shader_init(shader, data, length);
	return (vbyte *)shader;
}

extern "C" void hl_kore_compute_delete_shader(vbyte *shader) {
	kinc_compute_shader_t *sh = (kinc_compute_shader_t *)shader;
	kinc_compute_shader_destroy(sh);
	free(sh);
}

extern "C" vbyte *hl_kore_compute_get_constantlocation(vbyte *shader, vbyte *name) {
	kinc_compute_shader_t *sh = (kinc_compute_shader_t *)shader;
	kinc_compute_constant_location_t *location = (kinc_compute_constant_location_t *)malloc(sizeof(kinc_compute_constant_location_t));
	memcpy(location, &kinc_compute_shader_get_constant_location(sh, (char *)name), sizeof(kinc_compute_constant_location_t));
	return (vbyte *)location;
}

extern "C" vbyte *hl_kore_compute_get_textureunit(vbyte *shader, vbyte *name) {
	kinc_compute_shader_t *sh = (kinc_compute_shader_t *)shader;
	kinc_compute_texture_unit_t *unit = (kinc_compute_texture_unit_t *)malloc(sizeof(kinc_compute_texture_unit_t));
	memcpy(unit, &kinc_compute_shader_get_texture_unit(sh, (char *)name), sizeof(kinc_compute_texture_unit_t));
	return (vbyte *)unit;
}

extern "C" void hl_kore_compute_set_bool(vbyte *location, bool value) {
	kinc_compute_constant_location_t *loc = (kinc_compute_constant_location_t *)location;
	kinc_compute_set_bool(*loc, value);
}

extern "C" void hl_kore_compute_set_int(vbyte *location, int value) {
	kinc_compute_constant_location_t *loc = (kinc_compute_constant_location_t *)location;
	kinc_compute_set_int(*loc, value);
}

extern "C" void hl_kore_compute_set_float(vbyte *location, float value) {
	kinc_compute_constant_location_t *loc = (kinc_compute_constant_location_t *)location;
	kinc_compute_set_float(*loc, value);
}

extern "C" void hl_kore_compute_set_float2(vbyte *location, float value1, float value2) {
	kinc_compute_constant_location_t *loc = (kinc_compute_constant_location_t *)location;
	kinc_compute_set_float2(*loc, value1, value2);
}

extern "C" void hl_kore_compute_set_float3(vbyte *location, float value1, float value2, float value3) {
	kinc_compute_constant_location_t *loc = (kinc_compute_constant_location_t *)location;
	kinc_compute_set_float3(*loc, value1, value2, value3);
}

extern "C" void hl_kore_compute_set_float4(vbyte *location, float value1, float value2, float value3, float value4) {
	kinc_compute_constant_location_t *loc = (kinc_compute_constant_location_t *)location;
	kinc_compute_set_float4(*loc, value1, value2, value3, value4);
}

extern "C" void hl_kore_compute_set_floats(vbyte *location, vbyte *values, int count) {
	kinc_compute_constant_location_t *loc = (kinc_compute_constant_location_t *)location;
	kinc_compute_set_floats(*loc, (float *)values, count);
}

extern "C" void hl_kore_compute_set_matrix(vbyte *location, float _00, float _10, float _20, float _30, float _01, float _11, float _21, float _31, float _02,
                                           float _12, float _22, float _32, float _03, float _13, float _23, float _33) {
	kinc_compute_constant_location_t *loc = (kinc_compute_constant_location_t *)location;
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
	kinc_compute_set_matrix4(*loc, &value);
}

extern "C" void hl_kore_compute_set_matrix3(vbyte *location, float _00, float _10, float _20, float _01, float _11, float _21, float _02, float _12,
                                            float _22) {
	kinc_compute_constant_location_t *loc = (kinc_compute_constant_location_t *)location;
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
	kinc_compute_set_matrix3(*loc, &value);
}

extern "C" void hl_kore_compute_set_texture(vbyte *unit, vbyte *texture, int access) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	Kore::Graphics4::Texture *tex = (Kore::Graphics4::Texture *)texture;
	kinc_compute_set_texture(*u, &tex->kincTexture, (kinc_compute_access)access);
}

extern "C" void hl_kore_compute_set_target(vbyte *unit, vbyte *renderTarget, int access) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	Kore::Graphics4::RenderTarget *rt = (Kore::Graphics4::RenderTarget *)renderTarget;
	kinc_compute_set_render_target(*u, &rt->kincRenderTarget, (kinc_compute_access)access);
}

extern "C" void hl_kore_compute_set_sampled_texture(vbyte *unit, vbyte *texture) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	Kore::Graphics4::Texture *tex = (Kore::Graphics4::Texture *)texture;
	kinc_compute_set_sampled_texture(*u, &tex->kincTexture);
}

extern "C" void hl_kore_compute_set_sampled_target(vbyte *unit, vbyte *renderTarget) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	Kore::Graphics4::RenderTarget *rt = (Kore::Graphics4::RenderTarget *)renderTarget;
	kinc_compute_set_sampled_render_target(*u, &rt->kincRenderTarget);
}

extern "C" void hl_kore_compute_set_sampled_depth_target(vbyte *unit, vbyte *renderTarget) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	Kore::Graphics4::RenderTarget *rt = (Kore::Graphics4::RenderTarget *)renderTarget;
	kinc_compute_set_sampled_depth_from_render_target(*u, &rt->kincRenderTarget);
}

extern "C" void hl_kore_compute_set_sampled_cubemap_texture(vbyte *unit, vbyte *texture) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	Kore::Graphics4::Texture *tex = (Kore::Graphics4::Texture *)texture;
	kinc_compute_set_sampled_texture(*u, &tex->kincTexture);
}

extern "C" void hl_kore_compute_set_sampled_cubemap_target(vbyte *unit, vbyte *renderTarget) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	Kore::Graphics4::RenderTarget *rt = (Kore::Graphics4::RenderTarget *)renderTarget;
	kinc_compute_set_sampled_render_target(*u, &rt->kincRenderTarget);
}

extern "C" void hl_kore_compute_set_sampled_cubemap_depth_target(vbyte *unit, vbyte *renderTarget) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	Kore::Graphics4::RenderTarget *rt = (Kore::Graphics4::RenderTarget *)renderTarget;
	kinc_compute_set_sampled_depth_from_render_target(*u, &rt->kincRenderTarget);
}

extern "C" void hl_kore_compute_set_texture_parameters(vbyte *unit, int uAddressing, int vAddressing, int minificationFilter, int magnificationFilter,
                                                       int mipmapFilter) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	kinc_compute_set_texture_addressing(*u, KINC_G4_TEXTURE_DIRECTION_U, (kinc_g4_texture_addressing_t)uAddressing);
	kinc_compute_set_texture_addressing(*u, KINC_G4_TEXTURE_DIRECTION_V, (kinc_g4_texture_addressing_t)vAddressing);
	kinc_compute_set_texture_minification_filter(*u, (kinc_g4_texture_filter_t)minificationFilter);
	kinc_compute_set_texture_magnification_filter(*u, (kinc_g4_texture_filter_t)magnificationFilter);
	kinc_compute_set_texture_mipmap_filter(*u, (kinc_g4_mipmap_filter_t)mipmapFilter);
}

extern "C" void hl_kore_compute_set_texture3d_parameters(vbyte *unit, int uAddressing, int vAddressing, int wAddressing, int minificationFilter,
                                                         int magnificationFilter, int mipmapFilter) {
	kinc_compute_texture_unit_t *u = (kinc_compute_texture_unit_t *)unit;
	kinc_compute_set_texture3d_addressing(*u, KINC_G4_TEXTURE_DIRECTION_U, (kinc_g4_texture_addressing_t)uAddressing);
	kinc_compute_set_texture3d_addressing(*u, KINC_G4_TEXTURE_DIRECTION_V, (kinc_g4_texture_addressing_t)vAddressing);
	kinc_compute_set_texture3d_addressing(*u, KINC_G4_TEXTURE_DIRECTION_W, (kinc_g4_texture_addressing_t)wAddressing);
	kinc_compute_set_texture3d_minification_filter(*u, (kinc_g4_texture_filter_t)minificationFilter);
	kinc_compute_set_texture3d_magnification_filter(*u, (kinc_g4_texture_filter_t)magnificationFilter);
	kinc_compute_set_texture3d_mipmap_filter(*u, (kinc_g4_mipmap_filter_t)mipmapFilter);
}

extern "C" void hl_kore_compute_set_shader(vbyte *shader) {
	kinc_compute_set_shader((kinc_compute_shader_t *)shader);
}

extern "C" void hl_kore_compute_compute(int x, int y, int z) {
	kinc_compute(x, y, z);
}
