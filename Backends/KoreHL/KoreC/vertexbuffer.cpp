#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
#include <hl.h>

extern "C" int hl_kore_create_vertexstructure() {
	return (int)new Kore::VertexStructure();
}

extern "C" void hl_kore_vertexstructure_add(int structure, vbyte *name, int data) {
	Kore::VertexStructure* struc = (Kore::VertexStructure*)structure;
	struc->add((char*)name, (Kore::VertexData)data);
}

extern "C" int hl_kore_create_vertexbuffer(int vertexCount, int structure, int stepRate) {
	Kore::VertexStructure* struc = (Kore::VertexStructure*)structure;
	return (int)new Kore::VertexBuffer(vertexCount, *struc, stepRate);
}

extern "C" void* hl_kore_vertexbuffer_lock(int buffer) {
	Kore::VertexBuffer* buf = (Kore::VertexBuffer*)buffer;
	return buf->lock();
}

extern "C" void hl_kore_vertexbuffer_unlock(int buffer) {
	Kore::VertexBuffer* buf = (Kore::VertexBuffer*)buffer;
	buf->unlock();
}

extern "C" int hl_kore_vertexbuffer_count(int buffer) {
	Kore::VertexBuffer* buf = (Kore::VertexBuffer*)buffer;
	return buf->count();
}

extern "C" int hl_kore_vertexbuffer_stride(int buffer) {
	Kore::VertexBuffer* buf = (Kore::VertexBuffer*)buffer;
	return buf->stride();
}
