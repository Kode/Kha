#include <Kore/Graphics4/Graphics.h>
#include <hl.h>

extern "C" vbyte *hl_kore_create_indexbuffer(int count) {
	return (vbyte*)new Kore::Graphics4::IndexBuffer(count);
}

extern "C" void hl_kore_delete_indexbuffer(vbyte *buffer) {
	Kore::Graphics4::IndexBuffer* buf = (Kore::Graphics4::IndexBuffer*)buffer;
	delete buf;
}

extern "C" vbyte *hl_kore_indexbuffer_lock(vbyte *buffer) {
	Kore::Graphics4::IndexBuffer* buf = (Kore::Graphics4::IndexBuffer*)buffer;
	return (vbyte*)buf->lock();
}

extern "C" void hl_kore_indexbuffer_unlock(vbyte *buffer) {
	Kore::Graphics4::IndexBuffer* buf = (Kore::Graphics4::IndexBuffer*)buffer;
	buf->unlock();
}
