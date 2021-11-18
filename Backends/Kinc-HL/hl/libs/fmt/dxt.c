#define HL_NAME(n) fmt_##n
#include <hl.h>

static const int BIT5[] = { 0, 8, 16, 25, 33, 41, 49, 58, 66, 74, 82, 90, 99, 107, 115, 123, 132, 140, 148, 156, 165, 173, 181, 189, 197, 206, 214, 222, 230, 239, 247, 255 };
static const int BIT6[] = { 0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 45, 49, 53, 57, 61, 65, 69, 73, 77, 81, 85, 89, 93, 97, 101, 105, 109, 113, 117, 121, 125, 130, 134, 138, 142, 146, 150, 154, 158, 162, 166, 170, 174, 178, 182, 186, 190, 194, 198, 202, 206, 210, 215, 219, 223, 227, 231, 235, 239, 243, 247, 251, 255 };

#define MK_COLOR(r,g,b,a) (((a)<<24) | ((b)<<16) | ((g)<<8) | (r))

#define DXT_COLOR1(c,a) MK_COLOR( \
	BIT5[(c & 0xFC00) >> 11], \
	BIT6[(c & 0x07E0) >> 5], \
	BIT5[(c & 0x001F)], \
	a)

#define DXT_COLOR2(c0,c1,a) MK_COLOR( \
	(BIT5[(c0 & 0xFC00) >> 11] + BIT5[(c1 & 0xFC00) >> 11]) / 2, \
	(BIT6[(c0 & 0x07E0) >> 5] + BIT6[(c1 & 0x07E0) >> 5]) / 2, \
	(BIT5[c0 & 0x001F] + BIT5[c1 & 0x001F]) / 2, \
	a)

#define DXT_COLOR3(c0,c1,a) MK_COLOR( \
	(2 * BIT5[(c0 & 0xFC00) >> 11] + BIT5[(c1 & 0xFC00) >> 11]) / 3, \
	(2 * BIT6[(c0 & 0x07E0) >> 5] + BIT6[(c1 & 0x07E0) >> 5]) / 3, \
	(2 * BIT5[c0 & 0x001F] + BIT5[c1 & 0x001F]) / 3, \
	a)

static int dxtAlpha(int a0, int a1, int t) {
	if (a0 > a1) switch (t) {
	case 0: return a0;
	case 1: return a1;
	case 2: return (6 * a0 + a1) / 7;
	case 3: return (5 * a0 + 2 * a1) / 7;
	case 4: return (4 * a0 + 3 * a1) / 7;
	case 5: return (3 * a0 + 4 * a1) / 7;
	case 6: return (2 * a0 + 5 * a1) / 7;
	case 7: return (a0 + 6 * a1) / 7;
	}
	else switch (t) {
	case 0: return a0;
	case 1: return a1;
	case 2: return (4 * a0 + a1) / 5;
	case 3: return (3 * a0 + 2 * a1) / 5;
	case 4: return (2 * a0 + 3 * a1) / 5;
	case 5: return (a0 + 4 * a1) / 5;
	case 6: return 0;
	case 7: return 255;
	}
	return 0;
}

static int dxtColor(int c0, int c1, int a, int t) {
	switch (t) {
	case 0: return DXT_COLOR1(c0, a);
	case 1: return DXT_COLOR1(c1, a);
	case 2: return (c0 > c1) ? DXT_COLOR3(c0, c1, a) : DXT_COLOR2(c0, c1, a);
	case 3: return (c0 > c1) ? DXT_COLOR3(c1, c0, a) : 0;
	}
	return 0;
}

HL_PRIM bool HL_NAME(dxt_decode)( vbyte *data, int *out, int width, int height, int format ) {
	int x,y,k;
	int index = 0;
	int write = 0;
	int alpha[16];
	switch( format ) {
	case 1:
		for(y=0;y<height>>2;y++) {
			for(x=0;x<width>>2;x++) {
				int c0 = data[index] | (data[index + 1] << 8); index += 2;
				int c1 = data[index] | (data[index + 1] << 8); index += 2;
				for(k=0;k<4;k++) {
					unsigned char c = data[index++];
					int t0 = c & 0x03;
					int t1 = (c & 0x0C) >> 2;
					int t2 = (c & 0x30) >> 4;
					int t3 = (c & 0xC0) >> 6;
					int w = write + k * width;
					out[w++] = dxtColor(c0, c1, 0xFF, t0);
					out[w++] = dxtColor(c0, c1, 0xFF, t1);
					out[w++] = dxtColor(c0, c1, 0xFF, t2);
					out[w++] = dxtColor(c0, c1, 0xFF, t3);
				}
				write += 4;
			}
			write += 3 * width;
		}
		return true;
	case 2:
		for(y=0;y<height>>2;y++) {
			for(x=0;x<width>>2;x++) {
				int ap = 0;
				for(k=0;k<4;k++) {
					int a0 = data[index++];
					int a1 = data[index++];
					alpha[ap++] = 17 * ((a0 & 0xF0) >> 4);
					alpha[ap++] = 17 * (a0 & 0x0F);
					alpha[ap++] = 17 * ((a1 & 0xF0) >> 4);
					alpha[ap++] = 17 * (a1 & 0x0F);
				}
				ap = 0;
				int c0 = data[index] | (data[index + 1] << 8); index += 2;
				int c1 = data[index] | (data[index + 1] << 8); index += 2;
				for (int k = 0; k<4; k++) {
					int c = data[index++];
					int t0 = c & 0x03;
					int t1 = (c & 0x0C) >> 2;
					int t2 = (c & 0x30) >> 4;
					int t3 = (c & 0xC0) >> 6;
					int w = write + k * width;
					out[w++] = dxtColor(c0, c1, alpha[ap++], t0);
					out[w++] = dxtColor(c0, c1, alpha[ap++], t1);
					out[w++] = dxtColor(c0, c1, alpha[ap++], t2);
					out[w++] = dxtColor(c0, c1, alpha[ap++], t3);
				}
				write += 4;
			}
			write += 3 * width;
		}
		return true;
	case 3:
		for(y=0;y<height>>2;y++) {
			for(x=0;x<width>>2;x++) {
				int a0 = data[index++];
				int a1 = data[index++];
				int b0 = data[index] | (data[index + 1] << 8) | (data[index + 2] << 16); index += 3;
				int b1 = data[index] | (data[index + 1] << 8) | (data[index + 2] << 16); index += 3;
				alpha[0] = b0 & 0x07;
				alpha[1] = (b0 >> 3) & 0x07;
				alpha[2] = (b0 >> 6) & 0x07;
				alpha[3] = (b0 >> 9) & 0x07;
				alpha[4] = (b0 >> 12) & 0x07;
				alpha[5] = (b0 >> 15) & 0x07;
				alpha[6] = (b0 >> 18) & 0x07;
				alpha[7] = (b0 >> 21) & 0x07;
				alpha[8] = b1 & 0x07;
				alpha[9] = (b1 >> 3) & 0x07;
				alpha[10] = (b1 >> 6) & 0x07;
				alpha[11] = (b1 >> 9) & 0x07;
				alpha[12] = (b1 >> 12) & 0x07;
				alpha[13] = (b1 >> 15) & 0x07;
				alpha[14] = (b1 >> 18) & 0x07;
				alpha[15] = (b1 >> 21) & 0x07;
				int c0 = data[index] | (data[index + 1] << 8); index += 2;
				int c1 = data[index] | (data[index + 1] << 8); index += 2;
				int ap = 0;
				for (int k = 0; k<4; k++) {
					int c = data[index++];
					int t0 = c & 0x03;
					int t1 = (c & 0x0C) >> 2;
					int t2 = (c & 0x30) >> 4;
					int t3 = (c & 0xC0) >> 6;
					int w = write + k * width;
					out[w++] = dxtColor(c0, c1, dxtAlpha(a0, a1, alpha[ap++]), t0);
					out[w++] = dxtColor(c0, c1, dxtAlpha(a0, a1, alpha[ap++]), t1);
					out[w++] = dxtColor(c0, c1, dxtAlpha(a0, a1, alpha[ap++]), t2);
					out[w++] = dxtColor(c0, c1, dxtAlpha(a0, a1, alpha[ap++]), t3);
				}
				write += 4;
			}
			write += 3 * width;
		}
		return true;
	default:
		return false;
	}
}

DEFINE_PRIM(_BOOL, dxt_decode, _BYTES _BYTES _I32 _I32 _I32);
