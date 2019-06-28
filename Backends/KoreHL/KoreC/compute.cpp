#include <Kore/pch.h>
#include <Kore/Compute/Compute.h>
#include <Kore/Graphics4/Graphics.h>
#include <hl.h>
#include <Kore/Log.h>

extern "C" vbyte* hl_kore_compute_create_shader(vbyte* data, int length) {
	return (vbyte*)new Kore::ComputeShader(data, length);
}

extern "C" void hl_kore_compute_delete_shader(vbyte* shader) {
	Kore::ComputeShader* sh = (Kore::ComputeShader*)shader;
	delete sh;
}

extern "C" vbyte* hl_kore_compute_get_constantlocation(vbyte* shader, vbyte* name) {
	Kore::ComputeShader* sh = (Kore::ComputeShader*)shader;
	return (vbyte*)new Kore::ComputeConstantLocation(sh->getConstantLocation((char*)name));	
}

extern "C" vbyte* hl_kore_compute_get_textureunit(vbyte* shader, vbyte* name) {
	Kore::ComputeShader* sh = (Kore::ComputeShader*)shader;
	return (vbyte*)new Kore::ComputeTextureUnit(sh->getTextureUnit((char*)name));
}

extern "C" void hl_kore_compute_set_bool(vbyte *location, bool value) {
	Kore::ComputeConstantLocation* loc = (Kore::ComputeConstantLocation*)location;
	Kore::Compute::setBool(*loc, value);
}

extern "C" void hl_kore_compute_set_int(vbyte *location, int value) {
	Kore::ComputeConstantLocation* loc = (Kore::ComputeConstantLocation*)location;
	Kore::Compute::setInt(*loc, value);
}

extern "C" void hl_kore_compute_set_float(vbyte *location, float value) {
	Kore::ComputeConstantLocation* loc = (Kore::ComputeConstantLocation*)location;
	Kore::Compute::setFloat(*loc, value);
}

extern "C" void hl_kore_compute_set_float2(vbyte *location, float value1, float value2) {
	Kore::ComputeConstantLocation* loc = (Kore::ComputeConstantLocation*)location;
	Kore::Compute::setFloat2(*loc, value1, value2);
}

extern "C" void hl_kore_compute_set_float3(vbyte *location, float value1, float value2, float value3) {
	Kore::ComputeConstantLocation* loc = (Kore::ComputeConstantLocation*)location;
	Kore::Compute::setFloat3(*loc, value1, value2, value3);
}

extern "C" void hl_kore_compute_set_float4(vbyte *location, float value1, float value2, float value3, float value4) {
	Kore::ComputeConstantLocation* loc = (Kore::ComputeConstantLocation*)location;
	Kore::Compute::setFloat4(*loc, value1, value2, value3, value4);
}

extern "C" void hl_kore_compute_set_floats(vbyte *location, vbyte *values, int count) {
	Kore::ComputeConstantLocation* loc = (Kore::ComputeConstantLocation*)location;
	Kore::Compute::setFloats(*loc, (float*)values, count);
}

extern "C" void hl_kore_compute_set_matrix(vbyte *location,
	float _00, float _10, float _20, float _30,
	float _01, float _11, float _21, float _31,
	float _02, float _12, float _22, float _32,
	float _03, float _13, float _23, float _33) {
	Kore::ComputeConstantLocation* loc = (Kore::ComputeConstantLocation*)location;
	Kore::mat4 value;
	value.Set(0, 0, _00); value.Set(1, 0, _01); value.Set(2, 0, _02); value.Set(3, 0, _03);
	value.Set(0, 1, _10); value.Set(1, 1, _11); value.Set(2, 1, _12); value.Set(3, 1, _13);
	value.Set(0, 2, _20); value.Set(1, 2, _21); value.Set(2, 2, _22); value.Set(3, 2, _23);
	value.Set(0, 3, _30); value.Set(1, 3, _31); value.Set(2, 3, _32); value.Set(3, 3, _33);
	Kore::Compute::setMatrix(*loc, value);
}

extern "C" void hl_kore_compute_set_matrix3(vbyte *location,
	float _00, float _10, float _20,
	float _01, float _11, float _21,
	float _02, float _12, float _22) {
	Kore::ComputeConstantLocation* loc = (Kore::ComputeConstantLocation*)location;
	Kore::mat3 value;
	value.Set(0, 0, _00); value.Set(1, 0, _01); value.Set(2, 0, _02);
	value.Set(0, 1, _10); value.Set(1, 1, _11); value.Set(2, 1, _12);
	value.Set(0, 2, _20); value.Set(1, 2, _21); value.Set(2, 2, _22);
	Kore::Compute::setMatrix(*loc, value);
}

extern "C" void hl_kore_compute_set_texture(vbyte *unit, vbyte *texture, int access) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	Kore::Compute::setTexture(*u, tex, (Kore::Compute::Access)access);
}

extern "C" void hl_kore_compute_set_target(vbyte *unit, vbyte *renderTarget, int access) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	Kore::Compute::setTexture(*u, rt, (Kore::Compute::Access)access);
}

extern "C" void hl_kore_compute_set_sampled_texture(vbyte *unit, vbyte *texture) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	Kore::Compute::setSampledTexture(*u, tex);
}

extern "C" void hl_kore_compute_set_sampled_target(vbyte *unit, vbyte *renderTarget) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	Kore::Compute::setSampledTexture(*u, rt);
}

extern "C" void hl_kore_compute_set_sampled_depth_target(vbyte *unit, vbyte *renderTarget) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	Kore::Compute::setSampledDepthTexture(*u, rt);
}

extern "C" void hl_kore_compute_set_sampled_cubemap_texture(vbyte *unit, vbyte *texture) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	Kore::Compute::setSampledTexture(*u, tex);
}

extern "C" void hl_kore_compute_set_sampled_cubemap_target(vbyte *unit, vbyte *renderTarget) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	Kore::Compute::setSampledTexture(*u, rt);
}

extern "C" void hl_kore_compute_set_sampled_cubemap_depth_target(vbyte *unit, vbyte *renderTarget) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	Kore::Compute::setSampledDepthTexture(*u, rt);
}

extern "C" void hl_kore_compute_set_texture_parameters(vbyte *unit, int uAddressing, int vAddressing, int minificationFilter, int magnificationFilter, int mipmapFilter) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Compute::setTextureAddressing(*u, Kore::Graphics4::U, (Kore::Graphics4::TextureAddressing)uAddressing);
	Kore::Compute::setTextureAddressing(*u, Kore::Graphics4::V, (Kore::Graphics4::TextureAddressing)vAddressing);
	Kore::Compute::setTextureMinificationFilter(*u, (Kore::Graphics4::TextureFilter)minificationFilter);
	Kore::Compute::setTextureMagnificationFilter(*u, (Kore::Graphics4::TextureFilter)magnificationFilter);
	Kore::Compute::setTextureMipmapFilter(*u, (Kore::Graphics4::MipmapFilter)mipmapFilter);
}

extern "C" void hl_kore_compute_set_texture3d_parameters(vbyte *unit, int uAddressing, int vAddressing,int wAddressing, int minificationFilter, int magnificationFilter, int mipmapFilter) {
	Kore::ComputeTextureUnit* u = (Kore::ComputeTextureUnit*)unit;
	Kore::Compute::setTexture3DAddressing(*u, Kore::Graphics4::U, (Kore::Graphics4::TextureAddressing)uAddressing);
	Kore::Compute::setTexture3DAddressing(*u, Kore::Graphics4::V, (Kore::Graphics4::TextureAddressing)vAddressing);
	Kore::Compute::setTexture3DAddressing(*u, Kore::Graphics4::W, (Kore::Graphics4::TextureAddressing)wAddressing);
	Kore::Compute::setTexture3DMinificationFilter(*u, (Kore::Graphics4::TextureFilter)minificationFilter);
	Kore::Compute::setTexture3DMagnificationFilter(*u, (Kore::Graphics4::TextureFilter)magnificationFilter);
	Kore::Compute::setTexture3DMipmapFilter(*u, (Kore::Graphics4::MipmapFilter)mipmapFilter);
}

extern "C" void hl_kore_compute_set_shader(vbyte *shader) {
	Kore::ComputeShader* sh = (Kore::ComputeShader*)shader;
	Kore::Compute::setShader(sh);
}

extern "C" void hl_kore_compute_compute(int x, int y, int z) {
	Kore::Compute::compute(x, y, z);
}
