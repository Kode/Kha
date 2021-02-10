#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
#include <hl.h>

extern "C" vbyte *hl_kore_cubemap_create(int cubeMapSize, int depthBufferBits, int format, int stencilBufferBits, int contextId) {
	return (vbyte*)new Kore::Graphics4::RenderTarget(cubeMapSize, depthBufferBits, false, (Kore::Graphics4::RenderTargetFormat)format, stencilBufferBits, contextId);
}

extern "C" int hl_kore_cubemap_texture_get_width(vbyte *cubemap) {
	Kore::Graphics4::Texture* cm = (Kore::Graphics4::Texture*)cubemap;
	return cm->width;
}

extern "C" int hl_kore_cubemap_texture_get_height(vbyte *cubemap) {
	Kore::Graphics4::Texture* cm = (Kore::Graphics4::Texture*)cubemap;
	return cm->height;
}

extern "C" int hl_kore_cubemap_target_get_width(vbyte *cubemap) {
	Kore::Graphics4::RenderTarget* cm = (Kore::Graphics4::RenderTarget*)cubemap;
	return cm->width;
}

extern "C" int hl_kore_cubemap_target_get_height(vbyte *cubemap) {
	Kore::Graphics4::RenderTarget* cm = (Kore::Graphics4::RenderTarget*)cubemap;
	return cm->height;
}
