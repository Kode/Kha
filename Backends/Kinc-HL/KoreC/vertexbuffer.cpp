#include <Kore/Graphics4/Graphics.h>
#include <hl.h>

extern "C" vbyte *hl_kore_create_vertexstructure(bool instanced) {
	Kore::Graphics4::VertexStructure* struc = new Kore::Graphics4::VertexStructure();
	struc->instanced = instanced;
	return (vbyte*)struc;
}

extern "C" void hl_kore_vertexstructure_add(vbyte *structure, vbyte *name, int data) {
	Kore::Graphics4::VertexStructure* struc = (Kore::Graphics4::VertexStructure*)structure;
	struc->add((char*)name, (Kore::Graphics4::VertexData)data);
}

extern "C" vbyte *hl_kore_create_vertexbuffer(int vertexCount, vbyte *structure, int usage, int stepRate) {
	Kore::Graphics4::VertexStructure* struc = (Kore::Graphics4::VertexStructure*)structure;
	return (vbyte*)new Kore::Graphics4::VertexBuffer(vertexCount, *struc, (Kore::Graphics4::Usage)usage, stepRate);
}

extern "C" void hl_kore_delete_vertexbuffer(vbyte *buffer) {
	Kore::Graphics4::VertexBuffer* buf = (Kore::Graphics4::VertexBuffer*)buffer;
	delete buf;
}

extern "C" vbyte *hl_kore_vertexbuffer_lock(vbyte *buffer) {
	Kore::Graphics4::VertexBuffer* buf = (Kore::Graphics4::VertexBuffer*)buffer;
	return (vbyte*)buf->lock();
}

extern "C" void hl_kore_vertexbuffer_unlock(vbyte *buffer, int count) {
	Kore::Graphics4::VertexBuffer* buf = (Kore::Graphics4::VertexBuffer*)buffer;
	buf->unlock(count);
}

extern "C" int hl_kore_vertexbuffer_count(vbyte *buffer) {
	Kore::Graphics4::VertexBuffer* buf = (Kore::Graphics4::VertexBuffer*)buffer;
	return buf->count();
}

extern "C" int hl_kore_vertexbuffer_stride(vbyte *buffer) {
	Kore::Graphics4::VertexBuffer* buf = (Kore::Graphics4::VertexBuffer*)buffer;
	return buf->stride();
}
