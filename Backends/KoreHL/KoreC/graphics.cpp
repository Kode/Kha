#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
#include <hl.h>

extern "C" void hl_kore_graphics_clear(int flags, int color, float z, int stencil) {
	Kore::Graphics4::clear(flags, color, z, stencil);
}

extern "C" bool hl_kore_graphics_vsynced() {
	return true;// Kore::Graphics4::vsynced();
}

extern "C" int hl_kore_graphics_refreshrate() {
	return 60;// Kore::Graphics4::refreshRate();
}

extern "C" void hl_kore_graphics_viewport(int x, int y, int width, int height) {
	Kore::Graphics4::viewport(x, y, width, height);
}

extern "C" void hl_kore_graphics_set_vertexbuffer(vbyte *buffer) {
	Kore::Graphics4::VertexBuffer* buf = (Kore::Graphics4::VertexBuffer*)buffer;
	Kore::Graphics4::setVertexBuffer(*buf);
}

extern "C" void hl_kore_graphics_set_vertexbuffers(vbyte *b0, vbyte *b1, vbyte *b2, vbyte *b3, int count) {
	Kore::Graphics4::VertexBuffer* vertexBuffers[4] = {
		(Kore::Graphics4::VertexBuffer*)b0,
		(Kore::Graphics4::VertexBuffer*)b1,
		(Kore::Graphics4::VertexBuffer*)b2,
		(Kore::Graphics4::VertexBuffer*)b3
	};
	Kore::Graphics4::setVertexBuffers(vertexBuffers, count);
}

extern "C" void hl_kore_graphics_set_indexbuffer(vbyte *buffer) {
	Kore::Graphics4::IndexBuffer* buf = (Kore::Graphics4::IndexBuffer*)buffer;
	Kore::Graphics4::setIndexBuffer(*buf);
}

extern "C" void hl_kore_graphics_scissor(int x, int y, int width, int height) {
	Kore::Graphics4::scissor(x, y, width, height);
}

extern "C" void hl_kore_graphics_disable_scissor() {
	Kore::Graphics4::disableScissor();
}

extern "C" bool hl_kore_graphics_render_targets_inverted_y() {
	return Kore::Graphics4::renderTargetsInvertedY();
}

extern "C" void hl_kore_graphics_set_texture_parameters(vbyte *unit, int uAddressing, int vAddressing, int minificationFilter, int magnificationFilter, int mipmapFilter) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::setTextureAddressing(*u, Kore::Graphics4::U, (Kore::Graphics4::TextureAddressing)uAddressing);
	Kore::Graphics4::setTextureAddressing(*u, Kore::Graphics4::V, (Kore::Graphics4::TextureAddressing)vAddressing);
	Kore::Graphics4::setTextureMinificationFilter(*u, (Kore::Graphics4::TextureFilter)minificationFilter);
	Kore::Graphics4::setTextureMagnificationFilter(*u, (Kore::Graphics4::TextureFilter)magnificationFilter);
	Kore::Graphics4::setTextureMipmapFilter(*u, (Kore::Graphics4::MipmapFilter)mipmapFilter);
}

extern "C" void hl_kore_graphics_set_texture3d_parameters(vbyte *unit, int uAddressing, int vAddressing,int wAddressing, int minificationFilter, int magnificationFilter, int mipmapFilter) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::setTexture3DAddressing(*u, Kore::Graphics4::U, (Kore::Graphics4::TextureAddressing)uAddressing);
	Kore::Graphics4::setTexture3DAddressing(*u, Kore::Graphics4::V, (Kore::Graphics4::TextureAddressing)vAddressing);
	Kore::Graphics4::setTexture3DAddressing(*u, Kore::Graphics4::W, (Kore::Graphics4::TextureAddressing)wAddressing);
	Kore::Graphics4::setTexture3DMinificationFilter(*u, (Kore::Graphics4::TextureFilter)minificationFilter);
	Kore::Graphics4::setTexture3DMagnificationFilter(*u, (Kore::Graphics4::TextureFilter)magnificationFilter);
	Kore::Graphics4::setTexture3DMipmapFilter(*u, (Kore::Graphics4::MipmapFilter)mipmapFilter);
}

extern "C" void hl_kore_graphics_set_texture_compare_mode(vbyte *unit, bool enabled) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::setTextureCompareMode(*u, enabled);
}

extern "C" void hl_kore_graphics_set_cube_map_compare_mode(vbyte *unit, bool enabled) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::setCubeMapCompareMode(*u, enabled);
}

extern "C" void hl_kore_graphics_set_texture(vbyte *unit, vbyte *texture) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	Kore::Graphics4::setTexture(*u, tex);
}

extern "C" void hl_kore_graphics_set_texture_depth(vbyte *unit, vbyte *renderTarget) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	rt->useDepthAsTexture(*u);
}

extern "C" void hl_kore_graphics_set_texture_array(vbyte *unit, vbyte *textureArray) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::TextureArray* texArray = (Kore::Graphics4::TextureArray*)textureArray;
	Kore::Graphics4::setTextureArray(*u, texArray);
}

extern "C" void hl_kore_graphics_set_render_target(vbyte *unit, vbyte *renderTarget) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	rt->useColorAsTexture(*u);
}

extern "C" void hl_kore_graphics_set_cubemap_texture(vbyte *unit, vbyte *texture) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	Kore::Graphics4::setTexture(*u, tex);
}

extern "C" void hl_kore_graphics_set_cubemap_depth(vbyte *unit, vbyte *renderTarget) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	rt->useDepthAsTexture(*u);
}

extern "C" void hl_kore_graphics_set_image_texture(vbyte *unit, vbyte *texture) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	Kore::Graphics4::setImageTexture(*u, tex);
}

extern "C" void hl_kore_graphics_set_cubemap_target(vbyte *unit, vbyte *renderTarget) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	rt->useColorAsTexture(*u);
}

extern "C" void hl_kore_graphics_set_bool(vbyte *location, bool value) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setBool(*loc, value);
}

extern "C" void hl_kore_graphics_set_int(vbyte *location, int value) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setInt(*loc, value);
}

extern "C" void hl_kore_graphics_set_float(vbyte *location, float value) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloat(*loc, value);
}

extern "C" void hl_kore_graphics_set_float2(vbyte *location, float value1, float value2) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloat2(*loc, value1, value2);
}

extern "C" void hl_kore_graphics_set_float3(vbyte *location, float value1, float value2, float value3) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloat3(*loc, value1, value2, value3);
}

extern "C" void hl_kore_graphics_set_float4(vbyte *location, float value1, float value2, float value3, float value4) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloat4(*loc, value1, value2, value3, value4);
}

extern "C" void hl_kore_graphics_set_floats(vbyte *location, vbyte *values, int count) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloats(*loc, (float*)values, count);
}

extern "C" void hl_kore_graphics_set_matrix(vbyte *location,
	float _00, float _10, float _20, float _30,
	float _01, float _11, float _21, float _31,
	float _02, float _12, float _22, float _32,
	float _03, float _13, float _23, float _33) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::mat4 value;
	value.Set(0, 0, _00); value.Set(1, 0, _01); value.Set(2, 0, _02); value.Set(3, 0, _03);
	value.Set(0, 1, _10); value.Set(1, 1, _11); value.Set(2, 1, _12); value.Set(3, 1, _13);
	value.Set(0, 2, _20); value.Set(1, 2, _21); value.Set(2, 2, _22); value.Set(3, 2, _23);
	value.Set(0, 3, _30); value.Set(1, 3, _31); value.Set(2, 3, _32); value.Set(3, 3, _33);
	Kore::Graphics4::setMatrix(*loc, value);
}

extern "C" void hl_kore_graphics_set_matrix3(vbyte *location,
	float _00, float _10, float _20,
	float _01, float _11, float _21,
	float _02, float _12, float _22) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::mat3 value;
	value.Set(0, 0, _00); value.Set(1, 0, _01); value.Set(2, 0, _02);
	value.Set(0, 1, _10); value.Set(1, 1, _11); value.Set(2, 1, _12);
	value.Set(0, 2, _20); value.Set(1, 2, _21); value.Set(2, 2, _22);
	Kore::Graphics4::setMatrix(*loc, value);
}

extern "C" void hl_kore_graphics_draw_all_indexed_vertices() {
	Kore::Graphics4::drawIndexedVertices();
}

extern "C" void hl_kore_graphics_draw_indexed_vertices(int start, int count) {
	Kore::Graphics4::drawIndexedVertices(start, count);
}

extern "C" void hl_kore_graphics_draw_all_indexed_vertices_instanced(int instanceCount) {
	Kore::Graphics4::drawIndexedVerticesInstanced(instanceCount);
}

extern "C" void hl_kore_graphics_draw_indexed_vertices_instanced(int instanceCount, int start, int count) {
	Kore::Graphics4::drawIndexedVerticesInstanced(instanceCount, start, count);
}

extern "C" void hl_kore_graphics_restore_render_target() {
	Kore::Graphics4::restoreRenderTarget();
}

extern "C" void hl_kore_graphics_render_to_texture(vbyte *renderTarget) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	Kore::Graphics4::setRenderTarget(rt);
}

extern "C" void hl_kore_graphics_render_to_textures(vbyte *rt0, vbyte *rt1, vbyte *rt2, vbyte *rt3, vbyte *rt4, vbyte *rt5, vbyte *rt6, vbyte *rt7, int count) {
	Kore::Graphics4::RenderTarget* t0 = (Kore::Graphics4::RenderTarget*)rt0;
	Kore::Graphics4::RenderTarget* t1 = (Kore::Graphics4::RenderTarget*)rt1;
	Kore::Graphics4::RenderTarget* t2 = (Kore::Graphics4::RenderTarget*)rt2;
	Kore::Graphics4::RenderTarget* t3 = (Kore::Graphics4::RenderTarget*)rt3;
	Kore::Graphics4::RenderTarget* t4 = (Kore::Graphics4::RenderTarget*)rt4;
	Kore::Graphics4::RenderTarget* t5 = (Kore::Graphics4::RenderTarget*)rt5;
	Kore::Graphics4::RenderTarget* t6 = (Kore::Graphics4::RenderTarget*)rt6;
	Kore::Graphics4::RenderTarget* t7 = (Kore::Graphics4::RenderTarget*)&rt7;
	Kore::Graphics4::RenderTarget* targets[8] = { t0, t1, t2, t3, t4, t5, t6, t7 };
	Kore::Graphics4::setRenderTargets(targets, count);
}

extern "C" void hl_kore_graphics_render_to_face(vbyte *renderTarget, int face) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	Kore::Graphics4::setRenderTargetFace(rt, face);
}

extern "C" void hl_kore_graphics_flush() {
	Kore::Graphics4::flush();
}
