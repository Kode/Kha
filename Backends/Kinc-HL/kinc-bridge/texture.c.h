#include <kinc/graphics4/graphics.h>
#include <kinc/image.h>
#include <kinc/video.h>

#include <hl.h>

#include <assert.h>

typedef struct tex_and_data {
	kinc_g4_texture_t texture;
	int width, height;
	void *data;
} tex_and_data_t;

static kinc_image_format_t convertImageFormat(int format) {
	switch (format) {
	default:
	case 0:
		return KINC_IMAGE_FORMAT_RGBA32;
	case 1:
		return KINC_IMAGE_FORMAT_GREY8;
	case 2:
		return KINC_IMAGE_FORMAT_RGBA128;
	case 4:
		return KINC_IMAGE_FORMAT_RGBA64;
	case 5:
		return KINC_IMAGE_FORMAT_A32;
	case 6:
		return KINC_IMAGE_FORMAT_A16;
	}
}

static int sizeOf(kinc_image_format_t format) {
	switch (format) {
	case KINC_IMAGE_FORMAT_RGBA128:
		return 16;
	case KINC_IMAGE_FORMAT_RGBA32:
	case KINC_IMAGE_FORMAT_BGRA32:
		return 4;
	case KINC_IMAGE_FORMAT_RGBA64:
		return 8;
	case KINC_IMAGE_FORMAT_A32:
		return 4;
	case KINC_IMAGE_FORMAT_A16:
		return 2;
	case KINC_IMAGE_FORMAT_GREY8:
		return 1;
	case KINC_IMAGE_FORMAT_RGB24:
		return 3;
	}
	assert(false);
	return 0;
}

vbyte *hl_kinc_texture_create(int width, int height, int format, bool readable) {
	tex_and_data_t *texture = (tex_and_data_t *)malloc(sizeof(tex_and_data_t));
	kinc_image_format_t f = convertImageFormat(format);
	kinc_g4_texture_init(&texture->texture, width, height, f);
	texture->width = width;
	texture->height = height;
	if (readable) {
		texture->data = malloc(width * height * sizeOf(f));
	}
	else {
		texture->data = NULL;
	}
	return (vbyte *)texture;
}

vbyte *hl_kinc_texture_create_from_file(vbyte *filename, bool readable) {
	size_t size = kinc_image_size_from_file((char *)filename);
	if (size > 0) {
		tex_and_data_t *texture = (tex_and_data_t *)malloc(sizeof(tex_and_data_t));
		texture->data = malloc(size);
		kinc_image_t image;
		if (kinc_image_init_from_file(&image, texture->data, (char *)filename) != 0) {
			kinc_g4_texture_init_from_image(&texture->texture, &image);
			texture->width = image.width;
			texture->height = image.height;
			if (!readable) {
				free(texture->data);
				texture->data = NULL;
			}
			kinc_image_destroy(&image);
			return (vbyte *)texture;
		}
		kinc_image_destroy(&image);
		free(texture->data);
		texture->data = NULL;
		free(texture);
	}
	return NULL;
}

vbyte *hl_kinc_texture_create3d(int width, int height, int depth, int format, bool readable) {
	tex_and_data_t *texture = (tex_and_data_t *)malloc(sizeof(tex_and_data_t));
	kinc_image_format_t f = convertImageFormat(format);
	kinc_g4_texture_init(&texture->texture, width, height, f);
	texture->width = width;
	texture->height = height;
	if (readable) {
		texture->data = malloc(width * height * depth * sizeOf(f));
	}
	else {
		texture->data = NULL;
	}
	return (vbyte *)texture;
}

vbyte *hl_kinc_video_get_current_image(vbyte *video) {
	kinc_video_t *v = (kinc_video_t *)video;
	return (vbyte *)kinc_video_current_image(v);
}

vbyte *hl_kinc_texture_from_bytes(vbyte *bytes, int width, int height, int format, bool readable) {
	kinc_image_format_t f = convertImageFormat(format);

	kinc_image_t image;
	kinc_image_init(&image, bytes, width, height, f);

	tex_and_data_t *texture = (tex_and_data_t *)malloc(sizeof(tex_and_data_t));
	kinc_g4_texture_init_from_image(&texture->texture, &image);
	texture->width = width;
	texture->height = height;

	kinc_image_destroy(&image);

	if (readable) {
		size_t size = width * height * sizeOf(f);
		texture->data = malloc(size);
		memcpy(texture->data, bytes, size);
	}
	else {
		texture->data = NULL;
	}

	return (vbyte *)texture;
}

vbyte *hl_kinc_texture_from_bytes3d(vbyte *bytes, int width, int height, int depth, int format, bool readable) {
	kinc_image_format_t f = convertImageFormat(format);

	kinc_image_t image;
	kinc_image_init3d(&image, bytes, width, height, depth, f);

	tex_and_data_t *texture = (tex_and_data_t *)malloc(sizeof(tex_and_data_t));
	kinc_g4_texture_init_from_image3d(&texture->texture, &image);
	texture->width = width;
	texture->height = height;

	kinc_image_destroy(&image);

	if (readable) {
		size_t size = width * height * depth * sizeOf(f);
		texture->data = malloc(size);
		memcpy(texture->data, bytes, size);
	}
	else {
		texture->data = NULL;
	}

	return (vbyte *)texture;
}

vbyte *hl_kinc_texture_from_encoded_bytes(vbyte *bytes, int length, vbyte *format, bool readable) {
	tex_and_data_t *texture = (tex_and_data_t *)malloc(sizeof(tex_and_data_t));

	size_t size = kinc_image_size_from_encoded_bytes(bytes, length, (char *)format);
	texture->data = malloc(size);

	kinc_image_t image;
	kinc_image_init_from_encoded_bytes(&image, texture->data, bytes, length, (char *)format);

	kinc_g4_texture_init_from_image(&texture->texture, &image);
	texture->width = image.width;
	texture->height = image.height;

	kinc_image_destroy(&image);

	if (!readable) {
		free(texture->data);
		texture->data = NULL;
	}

	return (vbyte *)texture;
}

bool hl_kinc_non_pow2_textures_supported(void) {
	return kinc_g4_non_pow2_textures_supported();
}

int hl_kinc_texture_get_width(vbyte *texture) {
	tex_and_data_t *tex = (tex_and_data_t *)texture;
	return tex->width;
}

int hl_kinc_texture_get_height(vbyte *texture) {
	tex_and_data_t *tex = (tex_and_data_t *)texture;
	return tex->height;
}

int hl_kinc_texture_get_real_width(vbyte *texture) {
	kinc_g4_texture_t *tex = (kinc_g4_texture_t *)texture;
	return tex->tex_width;
}

int hl_kinc_texture_get_real_height(vbyte *texture) {
	kinc_g4_texture_t *tex = (kinc_g4_texture_t *)texture;
	return tex->tex_height;
}

int hl_kinc_texture_at(vbyte *texture, int x, int y) {
	tex_and_data_t *tex = (tex_and_data_t *)texture;
	assert(tex->data != NULL);
	return *(int *)&((uint8_t *)tex->data)[tex->width * sizeOf(tex->texture.format) * y + x * sizeOf(tex->texture.format)];
}

void hl_kinc_texture_unload(vbyte *texture) {
	tex_and_data_t *tex = (tex_and_data_t *)texture;
	if (tex->data != NULL) {
		free(tex->data);
		tex->data = NULL;
	}
	kinc_g4_texture_destroy(&tex->texture);
	free(tex);
}

void hl_kinc_render_target_unload(vbyte *renderTarget) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_render_target_destroy(rt);
	free(rt);
}

vbyte *hl_kinc_render_target_create(int width, int height, int depthBufferBits, int format, int stencilBufferBits, int contextId) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)malloc(sizeof(kinc_g4_render_target_t));
	kinc_g4_render_target_init(rt, width, height, depthBufferBits, false, (kinc_g4_render_target_format_t)format, stencilBufferBits, contextId);
	return (vbyte *)rt;
}

int hl_kinc_render_target_get_width(vbyte *renderTarget) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	return rt->width;
}

int hl_kinc_render_target_get_height(vbyte *renderTarget) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	return rt->height;
}

int hl_kinc_render_target_get_real_width(vbyte *renderTarget) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	return rt->texWidth;
}

int hl_kinc_render_target_get_real_height(vbyte *renderTarget) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	return rt->texHeight;
}

void hl_kinc_texture_unlock(vbyte *texture, vbyte *bytes) {
	kinc_g4_texture_t *tex = (kinc_g4_texture_t *)texture;
	uint8_t *b = (uint8_t *)bytes;
	uint8_t *btex = kinc_g4_texture_lock(tex);
	int size = sizeOf(tex->format);
	int stride = kinc_g4_texture_stride(tex);
	for (int y = 0; y < tex->tex_height; ++y) {
		for (int x = 0; x < tex->tex_width; ++x) {
#ifdef KORE_DIRECT3D
			if (tex->format == KINC_IMAGE_FORMAT_RGBA32) {
				// RBGA->BGRA
				btex[y * stride + x * size + 0] = b[(y * tex->tex_width + x) * size + 2];
				btex[y * stride + x * size + 1] = b[(y * tex->tex_width + x) * size + 1];
				btex[y * stride + x * size + 2] = b[(y * tex->tex_width + x) * size + 0];
				btex[y * stride + x * size + 3] = b[(y * tex->tex_width + x) * size + 3];
			}
			else
#endif
			{
				for (int i = 0; i < size; ++i) {
					btex[y * stride + x * size + i] = b[(y * tex->tex_width + x) * size + i];
				}
			}
		}
	}
	kinc_g4_texture_unlock(tex);
}

void hl_kinc_render_target_get_pixels(vbyte *renderTarget, vbyte *pixels) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_render_target_get_pixels(rt, pixels);
}

void hl_kinc_generate_mipmaps_texture(vbyte *texture, int levels) {
	kinc_g4_texture_t *tex = (kinc_g4_texture_t *)texture;
	kinc_g4_texture_generate_mipmaps(tex, levels);
}

void hl_kinc_generate_mipmaps_target(vbyte *renderTarget, int levels) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_render_target_generate_mipmaps(rt, levels);
}

void hl_kinc_set_mipmap_texture(vbyte *texture, vbyte *mipmap, int level) {
	kinc_g4_texture_t *tex = (kinc_g4_texture_t *)texture;
	tex_and_data_t *miptex = (tex_and_data_t *)mipmap;
	assert(miptex->data != NULL);
	kinc_image_t mipimage;
	kinc_image_init(&mipimage, miptex->data, miptex->width, miptex->height, miptex->texture.format);
	kinc_g4_texture_set_mipmap(tex, &mipimage, level);
	kinc_image_destroy(&mipimage);
}

void hl_kinc_render_target_set_depth_stencil_from(vbyte *renderTarget, vbyte *from) {
	kinc_g4_render_target_t *rt = (kinc_g4_render_target_t *)renderTarget;
	kinc_g4_render_target_t *rt2 = (kinc_g4_render_target_t *)from;
	kinc_g4_render_target_set_depth_stencil_from(rt, rt2);
}

void hl_kinc_texture_clear(vbyte *texture, int x, int y, int z, int width, int height, int depth, int color) {
	kinc_g4_texture_t *tex = (kinc_g4_texture_t *)texture;
	kinc_g4_texture_clear(tex, x, y, z, width, height, depth, color);
}
