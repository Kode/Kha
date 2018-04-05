#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
#include <hl.h>

extern "C" void hl_kore_graphics_clear(int flags, int color, double z, int stencil) {
	Kore::Graphics4::clear(flags, color, z, stencil);
}

extern "C" bool hl_kore_graphics_vsynced() {
	return Kore::Graphics4::vsynced();
}

extern "C" int hl_kore_graphics_refreshrate() {
	return Kore::Graphics4::refreshRate();
}

extern "C" void hl_kore_graphics_viewport(int x, int y, int width, int height) {
	Kore::Graphics4::viewport(x, y, width, height);
}

extern "C" void hl_kore_graphics_set_vertexbuffer(vbyte *buffer) {
	Kore::Graphics4::VertexBuffer* buf = (Kore::Graphics4::VertexBuffer*)buffer;
	Kore::Graphics4::setVertexBuffer(*buf);
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

extern "C" void hl_kore_graphics_set_texture(vbyte *unit, vbyte *texture) {
	Kore::Graphics4::TextureUnit* u = (Kore::Graphics4::TextureUnit*)unit;
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	Kore::Graphics4::setTexture(*u, tex);
}

extern "C" void hl_kore_graphics_set_bool(vbyte *location, bool value) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setBool(*loc, value);
}

extern "C" void hl_kore_graphics_set_int(vbyte *location, int value) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setInt(*loc, value);
}

extern "C" void hl_kore_graphics_set_float(vbyte *location, double value) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloat(*loc, value);
}

extern "C" void hl_kore_graphics_set_float2(vbyte *location, double value1, double value2) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloat2(*loc, value1, value2);
}

extern "C" void hl_kore_graphics_set_float3(vbyte *location, double value1, double value2, double value3) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloat3(*loc, value1, value2, value3);
}

extern "C" void hl_kore_graphics_set_float4(vbyte *location, double value1, double value2, double value3, double value4) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloat4(*loc, value1, value2, value3, value4);
}

extern "C" void hl_kore_graphics_set_floats(vbyte *location, vbyte *values, int count) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::Graphics4::setFloats(*loc, (float*)values, count);
}

extern "C" void hl_kore_graphics_set_matrix(vbyte *location,
	double _00, double _10, double _20, double _30,
	double _01, double _11, double _21, double _31,
	double _02, double _12, double _22, double _32,
	double _03, double _13, double _23, double _33) {
	Kore::Graphics4::ConstantLocation* loc = (Kore::Graphics4::ConstantLocation*)location;
	Kore::mat4 value;
	value.Set(0, 0, _00); value.Set(1, 0, _01); value.Set(2, 0, _02); value.Set(3, 0, _03);
	value.Set(0, 1, _10); value.Set(1, 1, _11); value.Set(2, 1, _12); value.Set(3, 1, _13);
	value.Set(0, 2, _20); value.Set(1, 2, _21); value.Set(2, 2, _22); value.Set(3, 2, _23);
	value.Set(0, 3, _30); value.Set(1, 3, _31); value.Set(2, 3, _32); value.Set(3, 3, _33);
	Kore::Graphics4::setMatrix(*loc, value);
}

extern "C" void hl_kore_graphics_set_matrix3(vbyte *location,
	double _00, double _10, double _20,
	double _01, double _11, double _21,
	double _02, double _12, double _22) {
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

extern "C" void hl_kore_graphics_flush() {
	Kore::Graphics4::flush();
}
