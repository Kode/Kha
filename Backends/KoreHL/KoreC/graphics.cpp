#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
#include <hl.h>

extern "C" bool hl_kore_graphics_vsynced() {
	return Kore::Graphics::vsynced();
}

extern "C" int hl_kore_graphics_refreshrate() {
	return Kore::Graphics::refreshRate();
}

extern "C" void hl_kore_graphics_viewport(int x, int y, int width, int height) {
	Kore::Graphics::viewport(x, y, width, height);
}

extern "C" void hl_kore_graphics_set_vertexbuffer(int buffer) {
	Kore::VertexBuffer* buf = (Kore::VertexBuffer*)buffer;
	Kore::Graphics::setVertexBuffer(*buf);
}

extern "C" void hl_kore_graphics_set_indexbuffer(int buffer) {
	Kore::IndexBuffer* buf = (Kore::IndexBuffer*)buffer;
	Kore::Graphics::setIndexBuffer(*buf);
}

extern "C" void hl_kore_graphics_set_bool(int location, bool value) {
	Kore::ConstantLocation* loc = (Kore::ConstantLocation*)location;
	Kore::Graphics::setBool(*loc, value);
}

extern "C" void hl_kore_graphics_set_int(int location, int value) {
	Kore::ConstantLocation* loc = (Kore::ConstantLocation*)location;
	Kore::Graphics::setInt(*loc, value);
}

extern "C" void hl_kore_graphics_set_float(int location, double value) {
	Kore::ConstantLocation* loc = (Kore::ConstantLocation*)location;
	Kore::Graphics::setFloat(*loc, value);
}

extern "C" void hl_kore_graphics_set_float2(int location, double value1, double value2) {
	Kore::ConstantLocation* loc = (Kore::ConstantLocation*)location;
	Kore::Graphics::setFloat2(*loc, value1, value2);
}

extern "C" void hl_kore_graphics_set_float3(int location, double value1, double value2, double value3) {
	Kore::ConstantLocation* loc = (Kore::ConstantLocation*)location;
	Kore::Graphics::setFloat3(*loc, value1, value2, value3);
}

extern "C" void hl_kore_graphics_set_float4(int location, double value1, double value2, double value3, double value4) {
	Kore::ConstantLocation* loc = (Kore::ConstantLocation*)location;
	Kore::Graphics::setFloat4(*loc, value1, value2, value3, value4);
}

extern "C" void hl_kore_graphics_set_matrix(int location,
	double _00, double _10, double _20, double _30,
	double _01, double _11, double _21, double _31,
	double _02, double _12, double _22, double _32,
	double _03, double _13, double _23, double _33) {
	Kore::ConstantLocation* loc = (Kore::ConstantLocation*)location;
	Kore::mat4 value;
	value.Set(0, 0, _00); value.Set(0, 1, _01); value.Set(0, 2, _02); value.Set(0, 3, _03);
	value.Set(1, 0, _10); value.Set(1, 1, _11); value.Set(1, 2, _12); value.Set(1, 3, _13);
	value.Set(2, 0, _20); value.Set(2, 1, _21); value.Set(2, 2, _22); value.Set(2, 3, _23);
	value.Set(3, 0, _30); value.Set(3, 1, _31); value.Set(3, 2, _32); value.Set(3, 3, _33);
	Kore::Graphics::setMatrix(*loc, value);
}

extern "C" void hl_kore_graphics_draw_all_indexed_vertices() {
	Kore::Graphics::drawIndexedVertices();
}

extern "C" void hl_kore_graphics_draw_indexed_vertices(int start, int count) {
	Kore::Graphics::drawIndexedVertices(start, count);
}
