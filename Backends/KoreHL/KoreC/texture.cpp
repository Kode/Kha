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
