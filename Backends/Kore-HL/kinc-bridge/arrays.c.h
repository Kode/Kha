#include <hl.h>

#include <stdint.h>

vbyte *hl_kinc_bytebuffer_alloc(int elements) {
	char *data = (char *)malloc(elements * sizeof(char));
	return (vbyte *)data;
}

void hl_kinc_bytebuffer_free(vbyte *bytearray) {
	free(bytearray);
}

// Get

int hl_kinc_bytearray_getint8(vbyte *bytearray, int byteoffset) {
	return (int)*((int8_t *)&(bytearray[byteoffset]));
}

int hl_kinc_bytearray_getuint8(vbyte *bytearray, int byteoffset) {
	return (int)*((uint8_t *)&(bytearray[byteoffset]));
}

int hl_kinc_bytearray_getint16(vbyte *bytearray, int byteoffset) {
	return (int)*((int16_t *)&bytearray[byteoffset]);
}

int hl_kinc_bytearray_getuint16(vbyte *bytearray, int byteoffset) {
	return (int)*((uint16_t *)&bytearray[byteoffset]);
}

int hl_kinc_bytearray_getint32(vbyte *bytearray, int byteoffset) {
	return (int)*((int32_t *)&bytearray[byteoffset]);
}

int64_t hl_kinc_bytearray_getuint32(vbyte *bytearray, int byteoffset) {
	return (int64_t)*((uint32_t *)&bytearray[byteoffset]);
}

float hl_kinc_bytearray_getfloat32(vbyte *bytearray, int byteoffset) {
	return *((float *)&bytearray[byteoffset]);
}

double hl_kinc_bytearray_getfloat64(vbyte *bytearray, int byteoffset) {
	return *((double *)&bytearray[byteoffset]);
}

// Set

void hl_kinc_bytearray_setint8(vbyte *bytearray, int byteoffset, int value) {
	*((int8_t *)&bytearray[byteoffset]) = (int8_t)value;
}

void hl_kinc_bytearray_setuint8(vbyte *bytearray, int byteoffset, int value) {
	*((uint8_t *)&bytearray[byteoffset]) = (uint8_t)value;
}

void hl_kinc_bytearray_setint16(vbyte *bytearray, int byteoffset, int value) {
	*((int16_t *)&bytearray[byteoffset]) = (int16_t)value;
}

void hl_kinc_bytearray_setuint16(vbyte *bytearray, int byteoffset, int value) {
	*((uint16_t *)&bytearray[byteoffset]) = (uint16_t)value;
}

void hl_kinc_bytearray_setint32(vbyte *bytearray, int byteoffset, int value) {
	*((int32_t *)&bytearray[byteoffset]) = (int32_t)value;
}

void hl_kinc_bytearray_setuint32(vbyte *bytearray, int byteoffset, int64_t value) {
	*((uint32_t *)&bytearray[byteoffset]) = (uint32_t)value;
}

void hl_kinc_bytearray_setfloat32(vbyte *bytearray, int byteoffset, float value) {
	*((float *)&bytearray[byteoffset]) = value;
}

void hl_kinc_bytearray_setfloat64(vbyte *bytearray, int byteoffset, double value) {
	*((double *)&bytearray[byteoffset]) = value;
}

// Get (little endian on big endian system)

int hl_kinc_bytearray_getint16_le(vbyte *bytearray, int byteoffset) {
	return (int)(bytearray[byteoffset] << 0 | bytearray[byteoffset + 1] << 8);
}

int hl_kinc_bytearray_getuint16_le(vbyte *bytearray, int byteoffset) {
	return (int)(bytearray[byteoffset] << 0 | bytearray[byteoffset + 1] << 8);
}

int hl_kinc_bytearray_getint32_le(vbyte *bytearray, int byteoffset) {
	return (int)(bytearray[byteoffset] << 0 | bytearray[byteoffset + 1] << 8 | bytearray[byteoffset + 2] << 16 | bytearray[byteoffset + 3] << 24);
}

int64_t hl_kinc_bytearray_getuint32_le(vbyte *bytearray, int byteoffset) {
	return (int64_t)(bytearray[byteoffset] << 0 | bytearray[byteoffset + 1] << 8 | bytearray[byteoffset + 2] << 16 | bytearray[byteoffset + 3] << 24);
}

float hl_kinc_bytearray_getfloat32_le(vbyte *bytearray, int byteoffset) {
	int32_t v = (bytearray[byteoffset] << 0 | bytearray[byteoffset + 1] << 8 | bytearray[byteoffset + 2] << 16 | bytearray[byteoffset + 3] << 24);
	return *(float *)&v;
}

double hl_kinc_bytearray_getfloat64_le(vbyte *bytearray, int byteoffset) {
	int64_t v = ((int64_t)bytearray[byteoffset] << 0 | (int64_t)bytearray[byteoffset + 1] << 8 | (int64_t)bytearray[byteoffset + 2] << 16 |
	             (int64_t)bytearray[byteoffset + 3] << 24 | (int64_t)bytearray[byteoffset + 4] << 32 | (int64_t)bytearray[byteoffset + 5] << 40 |
	             (int64_t)bytearray[byteoffset + 6] << 48 | (int64_t)bytearray[byteoffset + 7] << 56);
	return *(double *)&v;
}

// Set (little endian on big endian system)

void hl_kinc_bytearray_setint16_le(vbyte *bytearray, int byteoffset, int value) {
	int16_t val = value;
	int8_t *data = (int8_t *)&(val);
	int16_t le_value = data[0] << 8 | data[1] << 0;
	*((int16_t *)&bytearray[byteoffset]) = le_value;
}

void hl_kinc_bytearray_setuint16_le(vbyte *bytearray, int byteoffset, int value) {
	uint16_t val = value;
	int8_t *data = (int8_t *)&(val);
	uint16_t le_value = data[0] << 8 | data[1] << 0;
	*((uint16_t *)&bytearray[byteoffset]) = le_value;
}

void hl_kinc_bytearray_setint32_le(vbyte *bytearray, int byteoffset, int value) {
	int8_t *data = (int8_t *)&(value);
	int32_t le_value = data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0;
	*((int32_t *)&bytearray[byteoffset]) = le_value;
}

void hl_kinc_bytearray_setuint32_le(vbyte *bytearray, int byteoffset, int64_t value) {
	uint32_t val = (uint32_t)value;
	int8_t *data = (int8_t *)&(val);
	uint32_t le_value = data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0;
	*((uint32_t *)&bytearray[byteoffset]) = le_value;
}

void hl_kinc_bytearray_setfloat32_le(vbyte *bytearray, int byteoffset, float value) {
	int8_t *data = (int8_t *)&value;
	int32_t le_value = (data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3] << 0);
	*((float *)&bytearray[byteoffset]) = *(float *)&le_value;
}

void hl_kinc_bytearray_setfloat64_le(vbyte *bytearray, int byteoffset, double value) {
	int8_t *data = (int8_t *)&value;
	int64_t le_value = (int64_t)data[0] << 56 | (int64_t)data[1] << 48 | (int64_t)data[2] << 40 | (int64_t)data[3] << 32 | (int64_t)data[4] << 24 |
	                   (int64_t)data[5] << 16 | (int64_t)data[6] << 8 | (int64_t)data[7] << 0;
	*((double *)&bytearray[byteoffset]) = *(double *)&le_value;
}

// Get (big endian on little endian system)

int hl_kinc_bytearray_getint16_be(vbyte *bytearray, int byteoffset) {
	return (int)(bytearray[byteoffset + 1] << 0 | bytearray[byteoffset] << 8);
}

int hl_kinc_bytearray_getuint16_be(vbyte *bytearray, int byteoffset) {
	return (int)(bytearray[byteoffset + 1] << 0 | bytearray[byteoffset] << 8);
}

int hl_kinc_bytearray_getint32_be(vbyte *bytearray, int byteoffset) {
	return (int)(bytearray[byteoffset + 3] << 0 | bytearray[byteoffset + 2] << 8 | bytearray[byteoffset + 1] << 16 | bytearray[byteoffset] << 24);
}

int64_t hl_kinc_bytearray_getuint32_be(vbyte *bytearray, int byteoffset) {
	return (int64_t)(bytearray[byteoffset + 3] << 0 | bytearray[byteoffset + 2] << 8 | bytearray[byteoffset + 1] << 16 | bytearray[byteoffset] << 24);
}

float hl_kinc_bytearray_getfloat32_be(vbyte *bytearray, int byteoffset) {
	int32_t v = (bytearray[byteoffset + 3] << 0 | bytearray[byteoffset + 2] << 8 | bytearray[byteoffset + 1] << 16 | bytearray[byteoffset] << 24);
	return *(float *)&v;
}

double hl_kinc_bytearray_getfloat64_be(vbyte *bytearray, int byteoffset) {
	int64_t v = ((int64_t)bytearray[byteoffset + 7] << 0 | (int64_t)bytearray[byteoffset + 6] << 8 | (int64_t)bytearray[byteoffset + 5] << 16 |
	             (int64_t)bytearray[byteoffset + 4] << 24 | (int64_t)bytearray[byteoffset + 3] << 32 | (int64_t)bytearray[byteoffset + 2] << 40 |
	             (int64_t)bytearray[byteoffset + 1] << 48 | (int64_t)bytearray[byteoffset] << 56);
	return *(double *)&v;
}

// Set (big endian on little endian system)

void hl_kinc_bytearray_setint16_be(vbyte *bytearray, int byteoffset, int value) {
	int8_t *data = (int8_t *)&value;
	int16_t be_value = data[1] << 8 | data[0] << 0;
	*((int16_t *)&bytearray[byteoffset]) = be_value;
}

void hl_kinc_bytearray_setuint16_be(vbyte *bytearray, int byteoffset, int value) {
	int8_t *data = (int8_t *)&value;
	uint16_t be_value = data[1] << 8 | data[0] << 0;
	*((uint16_t *)&bytearray[byteoffset]) = be_value;
}

void hl_kinc_bytearray_setint32_be(vbyte *bytearray, int byteoffset, int value) {
	int8_t *data = (int8_t *)&value;
	int32_t be_value = data[3] << 24 | data[2] << 16 | data[1] << 8 | data[0] << 0;
	*((int32_t *)&bytearray[byteoffset]) = be_value;
}

void hl_kinc_bytearray_setuint32_be(vbyte *bytearray, int byteoffset, int64_t value) {
	int8_t *data = (int8_t *)&value;
	uint32_t be_value = data[3] << 24 | data[2] << 16 | data[1] << 8 | data[0] << 0;
	*((uint32_t *)&bytearray[byteoffset]) = be_value;
}

void hl_kinc_bytearray_setfloat32_be(vbyte *bytearray, int byteoffset, float value) {
	int8_t *data = (int8_t *)&value;
	int32_t be_value = (data[3] << 24 | data[2] << 16 | data[1] << 8 | data[0] << 0);
	*((float *)&bytearray[byteoffset]) = *(float *)&be_value;
}

void hl_kinc_bytearray_setfloat64_be(vbyte *bytearray, int byteoffset, double value) {
	int8_t *data = (int8_t *)&value;
	int64_t be_value = (int64_t)data[7] << 56 | (int64_t)data[6] << 48 | (int64_t)data[5] << 40 | (int64_t)data[4] << 32 | (int64_t)data[3] << 24 |
	                   (int64_t)data[2] << 16 | (int64_t)data[1] << 8 | (int64_t)data[0] << 0;
	*((double *)&bytearray[byteoffset]) = *(double *)&be_value;
}
