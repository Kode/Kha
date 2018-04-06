#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
#include <hl.h>

extern "C" vbyte *hl_kore_texture_create(int width, int height, int format, bool readable) {
	return (vbyte*)new Kore::Graphics4::Texture(width, height, (Kore::Graphics4::Image::Format)format, readable);
}

extern "C" vbyte *hl_kore_texture_create_from_file(vbyte *filename, bool readable) {
	return (vbyte*)new Kore::Graphics4::Texture((char*)filename, readable);
}

extern "C" bool hl_kore_non_pow2_textures_supported() {
	return Kore::Graphics4::nonPow2TexturesSupported();
}

extern "C" int hl_kore_texture_get_width(vbyte *texture) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	return tex->width;
}

extern "C" int hl_kore_texture_get_height(vbyte *texture) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	return tex->height;
}

extern "C" int hl_kore_texture_get_real_width(vbyte *texture) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	return tex->texWidth;
}

extern "C" int hl_kore_texture_get_real_height(vbyte *texture) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	return tex->texHeight;
}

extern "C" vbyte *hl_kore_render_target_create(int width, int height, int depthBufferBits, int format, int stencilBufferBits, int contextId) {
	return (vbyte*)new Kore::Graphics4::RenderTarget(width, height, depthBufferBits, false, (Kore::Graphics4::RenderTargetFormat)format, stencilBufferBits, contextId);
}

extern "C" int hl_kore_render_target_get_width(vbyte *renderTarget) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	return rt->width;
}

extern "C" int hl_kore_render_target_get_height(vbyte *renderTarget) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	return rt->height;
}

extern "C" int hl_kore_render_target_get_real_width(vbyte *renderTarget) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	return rt->texWidth;
}

extern "C" int hl_kore_render_target_get_real_height(vbyte *renderTarget) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	return rt->texHeight;
}

extern "C" void hl_kore_render_target_set_depth_stencil_from(vbyte *renderTarget, vbyte *from) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	Kore::Graphics4::RenderTarget* rt2 = (Kore::Graphics4::RenderTarget*)from;
	rt->setDepthStencilFrom(rt2);
}
