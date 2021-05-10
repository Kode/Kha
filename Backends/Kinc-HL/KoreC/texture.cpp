#include <Kore/Graphics4/Graphics.h>
#include <Kore/Video.h>
#include <hl.h>

extern "C" vbyte *hl_kore_texture_create(int width, int height, int format, bool readable) {
	return (vbyte*)new Kore::Graphics4::Texture(width, height, (Kore::Graphics4::Image::Format)format, readable);
}

extern "C" vbyte *hl_kore_texture_create_from_file(vbyte *filename, bool readable) {
	return (vbyte*)new Kore::Graphics4::Texture((char*)filename, readable);
}

extern "C" vbyte *hl_kore_texture_create3d(int width, int height, int depth, int format, bool readable) {
	return (vbyte*)new Kore::Graphics4::Texture(width, height, depth, (Kore::Graphics4::Image::Format)format, readable);
}

extern "C" vbyte *hl_kore_video_get_current_image(vbyte *video) {
	return (vbyte*)((Kore::Video*)video)->currentImage();
}

extern "C" vbyte *hl_kore_texture_from_bytes(vbyte *bytes, int width, int height, int format, bool readable) {
	return (vbyte*)new Kore::Graphics4::Texture(bytes, width, height, (Kore::Graphics4::Image::Format)format, readable);
}

extern "C" vbyte *hl_kore_texture_from_bytes3d(vbyte *bytes, int width, int height, int depth, int format, bool readable) {
	return (vbyte*)new Kore::Graphics4::Texture(bytes, width, height, depth, (Kore::Graphics4::Image::Format)format, readable);
}

extern "C" vbyte *hl_kore_texture_from_encoded_bytes(vbyte *bytes, int length, vbyte *format, bool readable) {
	return (vbyte*)new Kore::Graphics4::Texture(bytes, length, (char*)format, readable);
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

extern "C" int hl_kore_texture_at(vbyte *texture, int x, int y) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	return tex->at(x, y);
}

extern "C" void hl_kore_texture_unload(vbyte *texture) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	delete tex;
}

extern "C" void hl_kore_render_target_unload(vbyte *renderTarget) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	delete rt;
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

extern "C" void hl_kore_texture_unlock(vbyte *texture, vbyte *bytes) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	Kore::u8* b = (Kore::u8*)bytes;
	Kore::u8* btex = tex->lock();
	int size = tex->sizeOf(tex->format);
	int stride = tex->stride();
	for (int y = 0; y < tex->height; ++y) {
		for (int x = 0; x < tex->width; ++x) {
#ifdef KORE_DIRECT3D
			if (tex->format == Kore::Graphics4::Image::RGBA32) {
				//RBGA->BGRA
				btex[y * stride + x * size + 0] = b[(y * tex->width + x) * size + 2];
				btex[y * stride + x * size + 1] = b[(y * tex->width + x) * size + 1];
				btex[y * stride + x * size + 2] = b[(y * tex->width + x) * size + 0];
				btex[y * stride + x * size + 3] = b[(y * tex->width + x) * size + 3];
			}
			else
#endif
			{
				for (int i = 0; i < size; ++i) {
					btex[y * stride + x * size + i] = b[(y * tex->width + x) * size + i];
				}
			}
		}
	}
	tex->unlock();
}

extern "C" void hl_kore_render_target_get_pixels(vbyte *renderTarget, vbyte *pixels) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	rt->getPixels(pixels);
}

extern "C" void hl_kore_generate_mipmaps_texture(vbyte *texture, int levels) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	return tex->generateMipmaps(levels);
}

extern "C" void hl_kore_generate_mipmaps_target(vbyte *renderTarget, int levels) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	return rt->generateMipmaps(levels);
}

extern "C" void hl_kore_set_mipmap_texture(vbyte *texture, vbyte *mipmap, int level) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	Kore::Graphics4::Texture* miptex = (Kore::Graphics4::Texture*)mipmap;
	return tex->setMipmap(miptex, level);
}

extern "C" void hl_kore_render_target_set_depth_stencil_from(vbyte *renderTarget, vbyte *from) {
	Kore::Graphics4::RenderTarget* rt = (Kore::Graphics4::RenderTarget*)renderTarget;
	Kore::Graphics4::RenderTarget* rt2 = (Kore::Graphics4::RenderTarget*)from;
	rt->setDepthStencilFrom(rt2);
}

extern "C" void hl_kore_texture_clear(vbyte *texture, int x, int y, int z, int width, int height, int depth, int color) {
	Kore::Graphics4::Texture* tex = (Kore::Graphics4::Texture*)texture;
	return tex->clear(x, y, z, width, height, depth, color);
}
