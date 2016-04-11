#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
#include <hl.h>

extern "C" vbyte *hl_kore_create_vertexstructure() {
	return (vbyte*)new Kore::VertexStructure();
}

extern "C" void hl_kore_vertexstructure_add(vbyte *structure, vbyte *name, int data) {
	Kore::VertexStructure* struc = (Kore::VertexStructure*)structure;
	struc->add((char*)name, (Kore::VertexData)data);
}

extern "C" vbyte *hl_kore_create_vertexbuffer(int vertexCount, vbyte *structure, int stepRate) {
	Kore::VertexStructure* struc = (Kore::VertexStructure*)structure;
	return (vbyte*)new Kore::VertexBuffer(vertexCount, *struc, stepRate);
}

extern "C" vbyte *hl_kore_vertexbuffer_lock(vbyte *buffer) {
	Kore::VertexBuffer* buf = (Kore::VertexBuffer*)buffer;
	return (vbyte*)buf->lock();
}

extern "C" void hl_kore_vertexbuffer_unlock(vbyte *buffer) {
	Kore::VertexBuffer* buf = (Kore::VertexBuffer*)buffer;
	buf->unlock();
}

extern "C" int hl_kore_vertexbuffer_count(vbyte *buffer) {
	Kore::VertexBuffer* buf = (Kore::VertexBuffer*)buffer;
	return buf->count();
}

extern "C" int hl_kore_vertexbuffer_stride(vbyte *buffer) {
	Kore::VertexBuffer* buf = (Kore::VertexBuffer*)buffer;
	return buf->stride();
}
