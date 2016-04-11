#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
#include <hl.h>

extern "C" vbyte *hl_kore_create_indexbuffer(int count) {
	return (vbyte*)new Kore::IndexBuffer(count);
}

extern "C" vbyte *hl_kore_indexbuffer_lock(vbyte *buffer) {
	Kore::IndexBuffer* buf = (Kore::IndexBuffer*)buffer;
	return (vbyte*)buf->lock();
}

extern "C" void hl_kore_indexbuffer_unlock(vbyte *buffer) {
	Kore::IndexBuffer* buf = (Kore::IndexBuffer*)buffer;
	buf->unlock();
}
