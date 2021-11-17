#define HL_NAME(n) fmt_##n
#include <png.h>
#include <hl.h>

#if defined(HL_CONSOLE) && !defined(HL_XBO)
extern bool sys_jpg_decode( vbyte *data, int dataLen, vbyte *out, int width, int height, int stride, int format, int flags );
#else
#	include <turbojpeg.h>
#endif

#include <zlib.h>
#include <vorbis/vorbisfile.h>

#define MINIMP3_IMPLEMENTATION
#define MINIMP3_FLOAT_OUTPUT
#include <minimp3.h>

/* ------------------------------------------------- IMG --------------------------------------------------- */

typedef struct {
	unsigned char a,r,g,b;
} pixel;

HL_PRIM bool HL_NAME(jpg_decode)( vbyte *data, int dataLen, vbyte *out, int width, int height, int stride, int format, int flags ) {
#if defined(HL_CONSOLE) && !defined(HL_XBO)
	hl_blocking(true);
	bool b = sys_jpg_decode(data, dataLen, out, width, height, stride, format, flags);
	hl_blocking(false);
	return b;
#else
	hl_blocking(true);
	tjhandle h = tjInitDecompress();
	int result;
	result = tjDecompress2(h,data,dataLen,out,width,stride,height,format,(flags & 1 ? TJFLAG_BOTTOMUP : 0));
	tjDestroy(h);
	hl_blocking(false);
	return result == 0;
#endif
}

HL_PRIM bool HL_NAME(png_decode)( vbyte *data, int dataLen, vbyte *out, int width, int height, int stride, int format, int flags ) {
#	ifdef PNG_IMAGE_VERSION
	png_image img;
	hl_blocking(true);
	memset(&img, 0, sizeof(img));
	img.version = PNG_IMAGE_VERSION;
	if( png_image_begin_read_from_memory(&img,data,dataLen) == 0 ) {
		hl_blocking(false);
		png_image_free(&img);
		return false;
	}
	switch( format ) {
	case 0:
		img.format = PNG_FORMAT_RGB;
		break;
	case 1:
		img.format = PNG_FORMAT_BGR;
		break;
	case 7:
		img.format = PNG_FORMAT_RGBA;
		break;
	case 8:
		img.format = PNG_FORMAT_BGRA;
		break;
	case 9:
		img.format = PNG_FORMAT_ABGR;
		break;
	case 10:
		img.format = PNG_FORMAT_ARGB;
		break;
	case 12:
		img.format = PNG_FORMAT_LINEAR_Y;
		break;
	case 13:
		img.format = PNG_FORMAT_LINEAR_RGB;
		break;
	case 14:
		img.format = PNG_FORMAT_LINEAR_RGB_ALPHA;
		break;
	default:
		hl_blocking(false);
		png_image_free(&img);
		hl_error("Unsupported format");
		break;
	}
	if( img.width != width || img.height != height ) {
		hl_blocking(false);
		png_image_free(&img);
		return false;
	}
	if( png_image_finish_read(&img,NULL,out,stride * (flags & 1 ? -1 : 1),NULL) == 0 ) {
		hl_blocking(false);
		png_image_free(&img);
		return false;
	}
	hl_blocking(false);
	png_image_free(&img);
#	else
	hl_error("PNG support is missing for this libPNG version");
#	endif
	return true;
}

HL_PRIM void HL_NAME(img_scale)( vbyte *out, int outPos, int outStride, int outWidth, int outHeight, vbyte *in, int inPos, int inStride, int inWidth, int inHeight, int flags ) {
	int x, y;
	float scaleX = outWidth <= 1 ? 0.0f : (float)((inWidth - 1.001f) / (outWidth - 1));
	float scaleY = outHeight <= 1 ? 0.0f : (float)((inHeight - 1.001f) / (outHeight - 1));
	out += outPos;
	in += inPos;
	hl_blocking(true);
	for(y=0;y<outHeight;y++) {
		for(x=0;x<outWidth;x++) {
			float fx = x * scaleX;
			float fy = y * scaleY;
			int ix = (int)fx;
			int iy = (int)fy;
			if( (flags & 1) == 0 ) {
				// nearest
				vbyte *rin = in + iy * inStride;
				*(pixel*)out = *(pixel*)(rin + (ix<<2));
				out += 4;
			} else {
				// bilinear
				float rx = fx - ix;
				float ry = fy - iy;
				float rx1 = 1.0f - rx;
				float ry1 = 1.0f - ry;
				int w1 = (int)(rx1 * ry1 * 256.0f);
				int w2 = (int)(rx * ry1 * 256.0f);
				int w3 = (int)(rx1 * ry * 256.0f);
				int w4 = (int)(rx * ry * 256.0f);
				vbyte *rin = in + iy * inStride;
				pixel p1 = *(pixel*)(rin + (ix<<2));
				pixel p2 = *(pixel*)(rin + ((ix + 1)<<2));
				pixel p3 = *(pixel*)(rin + inStride + (ix<<2));
				pixel p4 = *(pixel*)(rin + inStride + ((ix + 1)<<2));
				*out++ = (unsigned char)((p1.a * w1 + p2.a * w2 + p3.a * w3 + p4.a * w4 + 128)>>8);
				*out++ = (unsigned char)((p1.r * w1 + p2.r * w2 + p3.r * w3 + p4.r * w4 + 128)>>8);
				*out++ = (unsigned char)((p1.g * w1 + p2.g * w2 + p3.g * w3 + p4.g * w4 + 128)>>8);
				*out++ = (unsigned char)((p1.b * w1 + p2.b * w2 + p3.b * w3 + p4.b * w4 + 128)>>8);
			}
		}
		out += outStride - (outWidth << 2);
	}
	hl_blocking(false);
}


DEFINE_PRIM(_BOOL, jpg_decode, _BYTES _I32 _BYTES _I32 _I32 _I32 _I32 _I32);
DEFINE_PRIM(_BOOL, png_decode, _BYTES _I32 _BYTES _I32 _I32 _I32 _I32 _I32);
DEFINE_PRIM(_VOID, img_scale, _BYTES _I32 _I32 _I32 _I32 _BYTES _I32 _I32 _I32 _I32 _I32);


/* ------------------------------------------------- ZLIB --------------------------------------------------- */

typedef struct _fmt_zip fmt_zip;
struct _fmt_zip {
	void (*finalize)( fmt_zip * );
	z_stream *z;
	int flush;
	bool inflate;
};

static void free_stream_inf( fmt_zip *v ) {
	if( v->inflate )
		inflateEnd(v->z); // no error
	else
		deflateEnd(v->z);
	free(v->z);
	v->z = NULL;
	v->finalize = NULL;
}

static void zlib_error( z_stream *z, int err ) {
	hl_buffer *b = hl_alloc_buffer();
	vdynamic *d;
	hl_buffer_cstr(b, "ZLib Error : ");
	if( z && z->msg ) {
		hl_buffer_cstr(b,z->msg);
		hl_buffer_cstr(b," (");
	}
	d = hl_alloc_dynamic(&hlt_i32);
	d->v.i = err;
	hl_buffer_val(b,d);
	if( z && z->msg )
		hl_buffer_char(b,')');
	d = hl_alloc_dynamic(&hlt_bytes);
	d->v.ptr = hl_buffer_content(b,NULL);
	hl_throw(d);
}

HL_PRIM fmt_zip *HL_NAME(inflate_init)( int wbits ) {
	z_stream *z;
	int err;
	fmt_zip *s;
	if( wbits == 0 )
		wbits = MAX_WBITS;
	z = (z_stream*)malloc(sizeof(z_stream));
	memset(z,0,sizeof(z_stream));
	if( (err = inflateInit2(z,wbits)) != Z_OK ) {
		free(z);
		zlib_error(NULL,err);
	}
	s = (fmt_zip*)hl_gc_alloc_finalizer(sizeof(fmt_zip));
	s->finalize = free_stream_inf;
	s->flush = Z_NO_FLUSH;
	s->z = z;
	s->inflate = true;
	return s;
}

HL_PRIM fmt_zip *HL_NAME(deflate_init)( int level ) {
	z_stream *z;
	int err;
	fmt_zip *s;
	z = (z_stream*)malloc(sizeof(z_stream));
	memset(z,0,sizeof(z_stream));
	if( (err = deflateInit(z,level)) != Z_OK ) {
		free(z);
		zlib_error(NULL,err);
	}
	s = (fmt_zip*)hl_gc_alloc_finalizer(sizeof(fmt_zip));
	s->finalize = free_stream_inf;
	s->flush = Z_NO_FLUSH;
	s->z = z;
	s->inflate = false;
	return s;
}

HL_PRIM void HL_NAME(zip_end)( fmt_zip *z ) {
	free_stream_inf(z);
}

HL_PRIM void HL_NAME(zip_flush_mode)( fmt_zip *z, int flush ) {
	switch( flush ) {
	case 0:
		z->flush = Z_NO_FLUSH;
		break;
	case 1:
		z->flush = Z_SYNC_FLUSH;
		break;
	case 2:
		z->flush = Z_FULL_FLUSH;
		break;
	case 3:
		z->flush = Z_FINISH;
		break;
	case 4:
		z->flush = Z_BLOCK;
		break;
	default:
		hl_error("Invalid flush mode %d",flush);
		break;
	}
}

HL_PRIM bool HL_NAME(inflate_buffer)( fmt_zip *zip, vbyte *src, int srcpos, int srclen, vbyte *dst, int dstpos, int dstlen, int *read, int *write ) {
	int slen, dlen, err;
	z_stream *z = zip->z;
	slen = srclen - srcpos;
	dlen = dstlen - dstpos;
	if( srcpos < 0 || dstpos < 0 || slen < 0 || dlen < 0 )
		hl_error("Out of range");
	hl_blocking(true);
	z->next_in = (Bytef*)(src + srcpos);
	z->next_out = (Bytef*)(dst + dstpos);
	z->avail_in = slen;
	z->avail_out = dlen;
	if( (err = inflate(z,zip->flush)) < 0 ) {
		hl_blocking(false);
		zlib_error(z,err);
	}
	z->next_in = NULL;
	z->next_out = NULL;
	*read = slen - z->avail_in;
	*write = dlen - z->avail_out;
	hl_blocking(false);
	return err == Z_STREAM_END;
}

HL_PRIM bool HL_NAME(deflate_buffer)( fmt_zip *zip, vbyte *src, int srcpos, int srclen, vbyte *dst, int dstpos, int dstlen, int *read, int *write ) {
	int slen, dlen, err;
	z_stream *z = zip->z;
	slen = srclen - srcpos;
	dlen = dstlen - dstpos;
	if( srcpos < 0 || dstpos < 0 || slen < 0 || dlen < 0 )
		hl_error("Out of range");
	hl_blocking(true);
	z->next_in = (Bytef*)(src + srcpos);
	z->next_out = (Bytef*)(dst + dstpos);
	z->avail_in = slen;
	z->avail_out = dlen;
	if( (err = deflate(z,zip->flush)) < 0 ) {
		hl_blocking(false);
		zlib_error(z,err);
	}
	z->next_in = NULL;
	z->next_out = NULL;
	*read = slen - z->avail_in;
	*write = dlen - z->avail_out;
	hl_blocking(false);
	return err == Z_STREAM_END;
}

HL_PRIM int HL_NAME(deflate_bound)( fmt_zip *zip, int size ) {
	return deflateBound(zip->z,size);
}

#define _ZIP _ABSTRACT(fmt_zip)

DEFINE_PRIM(_ZIP, inflate_init, _I32);
DEFINE_PRIM(_ZIP, deflate_init, _I32);
DEFINE_PRIM(_I32, deflate_bound, _ZIP _I32);
DEFINE_PRIM(_VOID, zip_end, _ZIP);
DEFINE_PRIM(_VOID, zip_flush_mode, _ZIP _I32);
DEFINE_PRIM(_BOOL, inflate_buffer, _ZIP _BYTES _I32 _I32 _BYTES _I32 _I32 _REF(_I32) _REF(_I32));
DEFINE_PRIM(_BOOL, deflate_buffer, _ZIP _BYTES _I32 _I32 _BYTES _I32 _I32 _REF(_I32) _REF(_I32));

/* ----------------------------------------------- SOUND : OGG ------------------------------------------------ */

typedef struct _fmt_ogg fmt_ogg;
struct _fmt_ogg {
	void (*finalize)( fmt_ogg * );
	OggVorbis_File f;
	char *bytes;
	int pos;
	int size;
	int section;
};

static void ogg_finalize( fmt_ogg *o ) {
	ov_clear(&o->f);
}

static size_t ogg_memread( void *ptr, int size, int count, fmt_ogg *o ) {
	int len = size * count;
	if( o->pos + len > o->size )
		len = o->size - o->pos;
	memcpy(ptr, o->bytes + o->pos, len);
	o->pos += len;
	return len;
}

static int ogg_memseek( fmt_ogg *o, ogg_int64_t _offset, int mode ) {
	int offset = (int)_offset;
	switch( mode ) {
	case SEEK_SET:
		if( offset < 0 || offset > o->size ) return 1;
		o->pos = offset;
		break;
	case SEEK_CUR:
		if( o->pos + offset < 0 || o->pos + offset > o->size ) return 1;
		o->pos += offset;
		break;
	case SEEK_END:
		if( offset < 0 || offset > o->size ) return 1;
		o->pos = o->size - offset;
		break;
	}
	return 0;
}

static long ogg_memtell( fmt_ogg *o ) {
	return o->pos;
}

static ov_callbacks OV_CALLBACKS_MEMORY = {
  (size_t (*)(void *, size_t, size_t, void *))  ogg_memread,
  (int (*)(void *, ogg_int64_t, int))           ogg_memseek,
  (int (*)(void *))                             NULL,
  (long (*)(void *))                            ogg_memtell
};

HL_PRIM fmt_ogg *HL_NAME(ogg_open)( char *bytes, int size ) {
	fmt_ogg *o = (fmt_ogg*)hl_gc_alloc_finalizer(sizeof(fmt_ogg));
	o->finalize = NULL;
	o->bytes = bytes;
	o->size = size;
	o->pos = 0;
	if( ov_open_callbacks(o,&o->f,NULL,0,OV_CALLBACKS_MEMORY) != 0 )
		return NULL;
	o->finalize = ogg_finalize;
	return o;
}

HL_PRIM void HL_NAME(ogg_info)( fmt_ogg *o, int *bitrate, int *freq, int *samples, int *channels ) {
	vorbis_info *i = ov_info(&o->f,-1);
	*bitrate = i->bitrate_nominal;
	*freq = i->rate;
	*channels = i->channels;
	*samples = (int)ov_pcm_total(&o->f, -1);
}

HL_PRIM int HL_NAME(ogg_tell)( fmt_ogg *o ) {
	return (int)ov_pcm_tell(&o->f); // overflow at 12 hours @48 Khz
}

HL_PRIM bool HL_NAME(ogg_seek)( fmt_ogg *o, int sample ) {
	return ov_pcm_seek(&o->f,sample) == 0;
}

#define OGGFMT_I8			1
#define OGGFMT_I16			2
//#define OGGFMT_F32		3
#define OGGFMT_BIGENDIAN	128
#define OGGFMT_UNSIGNED		256

HL_PRIM int HL_NAME(ogg_read)( fmt_ogg *o, char *output, int size, int format ) {
	int ret = -1;
	hl_blocking(true);
	switch( format&127 ) {
	case OGGFMT_I8:
	case OGGFMT_I16:
		ret = ov_read(&o->f, output, size, (format & OGGFMT_BIGENDIAN) != 0, format&3, (format & OGGFMT_UNSIGNED) == 0, &o->section);
		break;
//	case OGGFMT_F32:
//		-- this decodes separates channels instead of mixed single buffer one
//		return ov_read_float(&o->f, output, size, (format & OGGFMT_BIGENDIAN) != 0, format&3, (format & OGGFMT_UNSIGNED) == 0, &o->section);
	default:
		break;
	}
	hl_blocking(false);
	return ret;
}

#define _OGG _ABSTRACT(fmt_ogg)

DEFINE_PRIM(_OGG, ogg_open, _BYTES _I32);
DEFINE_PRIM(_VOID, ogg_info, _OGG _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32));
DEFINE_PRIM(_I32, ogg_tell, _OGG);
DEFINE_PRIM(_BOOL, ogg_seek, _OGG _I32);
DEFINE_PRIM(_I32, ogg_read, _OGG _BYTES _I32 _I32);

/* ----------------------------------------------- SOUND : MP3 ------------------------------------------------ */

typedef struct _fmt_mp3 fmt_mp3;
struct _fmt_mp3 {
	mp3dec_t dec;
	mp3dec_frame_info_t info;
	mp3d_sample_t pcm[MINIMP3_MAX_SAMPLES_PER_FRAME];
};

// Allocate MP3 reader.
HL_PRIM fmt_mp3 *HL_NAME(mp3_open)() {
	fmt_mp3 *o = (fmt_mp3*)hl_gc_alloc_noptr(sizeof(fmt_mp3));
	mp3dec_init(&o->dec);
	return o;
}

/**
	Retreive last decoded frame information.
	@param bitrate_kbps Bitrate of the frame
	@param channels Total amount of channels in the frame.
	@param frame_bytes The size of the frame in the input stream,
	@param hz
	@param layer Mpeg Layer index (usually 3).
**/
HL_PRIM void HL_NAME(mp3_frame_info)(fmt_mp3 *o, int *bitrate_kbps, int *channels, int *frame_bytes, int *hz, int *layer) {
	*bitrate_kbps = o->info.bitrate_kbps;
	*channels = o->info.channels;
	*frame_bytes = o->info.frame_bytes;
	*hz = o->info.hz;
	*layer = o->info.layer;
}

/**
	Decodes a single frame from input stream and writes result to output.
	Decoded samples are in Float32 format. Output bytes should contain enough space to fit entire frame in.
	To calculate required output size, follow next formula: `samples * channels * 4`.
	For Layer 1, amount of frames is 384, MPEG 2 Layer 2 is 576 and 1152 otherwise. Using 1152 samples is the safest.
	@param o Allocated MP3 reader.
	@param bytes Input stream.
	@param size Input stream size.
	@param position Input stream offset.
	@param output Output stream.
	@param outputSize Output stream size.
	@param offset Output stream write offset.
	@returns 0 if no MP3 data was found (end of stream/invalid data), -1 if either input buffer position invalid or output size is insufficent.
		Amount of decoded samples otherwise.
**/
HL_PRIM int HL_NAME(mp3_decode_frame)( fmt_mp3 *o, char *bytes, int size, int position, char *output, int outputSize, int offset ) {

	// Out of mp3 file bounds.
	if ( position < 0 || size <= position )
		return -1;

	int samples = 0;
	hl_blocking(true);

	do {
		samples = mp3dec_decode_frame(&o->dec, (unsigned char*)bytes + position, size - position, o->pcm, &o->info);
		// Try to read until found mp3 data or EOF.
		if ( samples != 0 || o->info.frame_bytes == 0 )
			break;
		position += o->info.frame_bytes;
	} while ( size > position );

	// No or invalid MP3 data.
	if ( samples == 0 || o->info.frame_bytes == 0 ) {
		hl_blocking(false);
		return 0;
	}

	int decodedSize = samples * o->info.channels * sizeof(mp3d_sample_t);
	// Insufficent output buffer size.
	if ( outputSize - offset < decodedSize ) {
		hl_blocking(false);
		return -1;
	}

	memcpy( (void *)(output + offset), (void *)o->pcm, decodedSize );

	hl_blocking(false);
	return samples;
}

#define _MP3 _ABSTRACT(fmt_mp3)

DEFINE_PRIM(_MP3, mp3_open, _BYTES _I32);
DEFINE_PRIM(_VOID, mp3_frame_info, _MP3 _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32) _REF(_I32))
DEFINE_PRIM(_I32, mp3_decode_frame, _MP3 _BYTES _I32 _I32 _BYTES _I32 _I32);

/* ------------------------------------------------- CRYPTO --------------------------------------------------- */

typedef unsigned int uint32;
typedef unsigned char uint8;

typedef struct {
    uint32 total[2];
    uint32 state[4];
    uint8 buffer[64];
} md5_context;

#define GET_UINT32(n,b,i)                       \
{                                               \
    (n) = ( (uint32) (b)[(i)    ]       )       \
        | ( (uint32) (b)[(i) + 1] <<  8 )       \
        | ( (uint32) (b)[(i) + 2] << 16 )       \
        | ( (uint32) (b)[(i) + 3] << 24 );      \
}

#define PUT_UINT32(n,b,i)                       \
{                                               \
    (b)[(i)    ] = (uint8) ( (n)       );       \
    (b)[(i) + 1] = (uint8) ( (n) >>  8 );       \
    (b)[(i) + 2] = (uint8) ( (n) >> 16 );       \
    (b)[(i) + 3] = (uint8) ( (n) >> 24 );       \
}

static void md5_starts( md5_context *ctx ) {
    ctx->total[0] = 0;
    ctx->total[1] = 0;
    ctx->state[0] = 0x67452301;
    ctx->state[1] = 0xEFCDAB89;
    ctx->state[2] = 0x98BADCFE;
    ctx->state[3] = 0x10325476;
}

static void md5_process( md5_context *ctx, uint8 data[64] ) {
    uint32 X[16], A, B, C, D;
    GET_UINT32( X[0],  data,  0 );
    GET_UINT32( X[1],  data,  4 );
    GET_UINT32( X[2],  data,  8 );
    GET_UINT32( X[3],  data, 12 );
    GET_UINT32( X[4],  data, 16 );
    GET_UINT32( X[5],  data, 20 );
    GET_UINT32( X[6],  data, 24 );
    GET_UINT32( X[7],  data, 28 );
    GET_UINT32( X[8],  data, 32 );
    GET_UINT32( X[9],  data, 36 );
    GET_UINT32( X[10], data, 40 );
    GET_UINT32( X[11], data, 44 );
    GET_UINT32( X[12], data, 48 );
    GET_UINT32( X[13], data, 52 );
    GET_UINT32( X[14], data, 56 );
    GET_UINT32( X[15], data, 60 );

#define S(x,n) ((x << n) | ((x & 0xFFFFFFFF) >> (32 - n)))

#define P(a,b,c,d,k,s,t)                                \
{                                                       \
    a += F(b,c,d) + X[k] + t; a = S(a,s) + b;           \
}

    A = ctx->state[0];
    B = ctx->state[1];
    C = ctx->state[2];
    D = ctx->state[3];

#define F(x,y,z) (z ^ (x & (y ^ z)))

    P( A, B, C, D,  0,  7, 0xD76AA478 );
    P( D, A, B, C,  1, 12, 0xE8C7B756 );
    P( C, D, A, B,  2, 17, 0x242070DB );
    P( B, C, D, A,  3, 22, 0xC1BDCEEE );
    P( A, B, C, D,  4,  7, 0xF57C0FAF );
    P( D, A, B, C,  5, 12, 0x4787C62A );
    P( C, D, A, B,  6, 17, 0xA8304613 );
    P( B, C, D, A,  7, 22, 0xFD469501 );
    P( A, B, C, D,  8,  7, 0x698098D8 );
    P( D, A, B, C,  9, 12, 0x8B44F7AF );
    P( C, D, A, B, 10, 17, 0xFFFF5BB1 );
    P( B, C, D, A, 11, 22, 0x895CD7BE );
    P( A, B, C, D, 12,  7, 0x6B901122 );
    P( D, A, B, C, 13, 12, 0xFD987193 );
    P( C, D, A, B, 14, 17, 0xA679438E );
    P( B, C, D, A, 15, 22, 0x49B40821 );

#undef F

#define F(x,y,z) (y ^ (z & (x ^ y)))

    P( A, B, C, D,  1,  5, 0xF61E2562 );
    P( D, A, B, C,  6,  9, 0xC040B340 );
    P( C, D, A, B, 11, 14, 0x265E5A51 );
    P( B, C, D, A,  0, 20, 0xE9B6C7AA );
    P( A, B, C, D,  5,  5, 0xD62F105D );
    P( D, A, B, C, 10,  9, 0x02441453 );
    P( C, D, A, B, 15, 14, 0xD8A1E681 );
    P( B, C, D, A,  4, 20, 0xE7D3FBC8 );
    P( A, B, C, D,  9,  5, 0x21E1CDE6 );
    P( D, A, B, C, 14,  9, 0xC33707D6 );
    P( C, D, A, B,  3, 14, 0xF4D50D87 );
    P( B, C, D, A,  8, 20, 0x455A14ED );
    P( A, B, C, D, 13,  5, 0xA9E3E905 );
    P( D, A, B, C,  2,  9, 0xFCEFA3F8 );
    P( C, D, A, B,  7, 14, 0x676F02D9 );
    P( B, C, D, A, 12, 20, 0x8D2A4C8A );

#undef F
    
#define F(x,y,z) (x ^ y ^ z)

    P( A, B, C, D,  5,  4, 0xFFFA3942 );
    P( D, A, B, C,  8, 11, 0x8771F681 );
    P( C, D, A, B, 11, 16, 0x6D9D6122 );
    P( B, C, D, A, 14, 23, 0xFDE5380C );
    P( A, B, C, D,  1,  4, 0xA4BEEA44 );
    P( D, A, B, C,  4, 11, 0x4BDECFA9 );
    P( C, D, A, B,  7, 16, 0xF6BB4B60 );
    P( B, C, D, A, 10, 23, 0xBEBFBC70 );
    P( A, B, C, D, 13,  4, 0x289B7EC6 );
    P( D, A, B, C,  0, 11, 0xEAA127FA );
    P( C, D, A, B,  3, 16, 0xD4EF3085 );
    P( B, C, D, A,  6, 23, 0x04881D05 );
    P( A, B, C, D,  9,  4, 0xD9D4D039 );
    P( D, A, B, C, 12, 11, 0xE6DB99E5 );
    P( C, D, A, B, 15, 16, 0x1FA27CF8 );
    P( B, C, D, A,  2, 23, 0xC4AC5665 );

#undef F

#define F(x,y,z) (y ^ (x | ~z))

    P( A, B, C, D,  0,  6, 0xF4292244 );
    P( D, A, B, C,  7, 10, 0x432AFF97 );
    P( C, D, A, B, 14, 15, 0xAB9423A7 );
    P( B, C, D, A,  5, 21, 0xFC93A039 );
    P( A, B, C, D, 12,  6, 0x655B59C3 );
    P( D, A, B, C,  3, 10, 0x8F0CCC92 );
    P( C, D, A, B, 10, 15, 0xFFEFF47D );
    P( B, C, D, A,  1, 21, 0x85845DD1 );
    P( A, B, C, D,  8,  6, 0x6FA87E4F );
    P( D, A, B, C, 15, 10, 0xFE2CE6E0 );
    P( C, D, A, B,  6, 15, 0xA3014314 );
    P( B, C, D, A, 13, 21, 0x4E0811A1 );
    P( A, B, C, D,  4,  6, 0xF7537E82 );
    P( D, A, B, C, 11, 10, 0xBD3AF235 );
    P( C, D, A, B,  2, 15, 0x2AD7D2BB );
    P( B, C, D, A,  9, 21, 0xEB86D391 );

#undef F

    ctx->state[0] += A;
    ctx->state[1] += B;
    ctx->state[2] += C;
    ctx->state[3] += D;
}

static void md5_update( md5_context *ctx, uint8 *input, uint32 length ) {
    uint32 left, fill;
    if( !length )
		return;
    left = ctx->total[0] & 0x3F;
    fill = 64 - left;

    ctx->total[0] += length;
    ctx->total[0] &= 0xFFFFFFFF;

    if( ctx->total[0] < length )
        ctx->total[1]++;

    if( left && length >= fill ) {
        memcpy( (void *) (ctx->buffer + left),
                (void *) input, fill );
        md5_process( ctx, ctx->buffer );
        length -= fill;
        input  += fill;
        left = 0;
    }

    while( length >= 64 ) {
        md5_process( ctx, input );
        length -= 64;
        input  += 64;
    }

    if( length ) {
        memcpy( (void *) (ctx->buffer + left),
                (void *) input, length );
    }
}

static uint8 md5_padding[64] =
{
 0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

static void md5_finish( md5_context *ctx, uint8 digest[16] ) {
    uint32 last, padn;
    uint32 high, low;
    uint8 msglen[8];

    high = ( ctx->total[0] >> 29 )
         | ( ctx->total[1] <<  3 );
    low  = ( ctx->total[0] <<  3 );

    PUT_UINT32( low,  msglen, 0 );
    PUT_UINT32( high, msglen, 4 );

    last = ctx->total[0] & 0x3F;
    padn = ( last < 56 ) ? ( 56 - last ) : ( 120 - last );

    md5_update( ctx, md5_padding, padn );
    md5_update( ctx, msglen, 8 );

    PUT_UINT32( ctx->state[0], digest,  0 );
    PUT_UINT32( ctx->state[1], digest,  4 );
    PUT_UINT32( ctx->state[2], digest,  8 );
    PUT_UINT32( ctx->state[3], digest, 12 );
}

#include "sha1.h"

HL_PRIM void HL_NAME(digest)( vbyte *out, vbyte *in, int length, int format ) {
	if( format & 256 ) {
		in = (vbyte*)hl_to_utf8((uchar*)in);
		length = (int)strlen((char*)in);
	}
	hl_blocking(true);
	switch( format & 0xFF ) {
	case 0:
		{
			md5_context ctx;
			md5_starts(&ctx);
			md5_update(&ctx,in,(uint32)length);
			md5_finish(&ctx,out);
		}
		break;
	case 1:
		{
			SHA1_CTX ctx;
			sha1_init(&ctx);
			sha1_update(&ctx,in,length);
			sha1_final(&ctx,out);
		}
		break;
	case 2:
		*((int*)out) = crc32(*(int*)out, in, length);
		break;
	case 3:
		*((int*)out) = adler32(*(int*)out, in, length);
		break;
	default:
		hl_blocking(false);
		hl_error("Unknown digest format %d",format&0xFF);
		break;
	}
	hl_blocking(false);
}

DEFINE_PRIM(_VOID, digest, _BYTES _BYTES _I32 _I32);
