#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
#include <hl.h>

extern "C" int hl_kore_create_indexbuffer(int count) {
	return (int)new Kore::IndexBuffer(count);
}

extern "C" void* hl_kore_indexbuffer_lock(int buffer) {
	Kore::IndexBuffer* buf = (Kore::IndexBuffer*)buffer;
	return buf->lock();
}

extern "C" void hl_kore_indexbuffer_unlock(int buffer) {
	Kore::IndexBuffer* buf = (Kore::IndexBuffer*)buffer;
	buf->unlock();
}
