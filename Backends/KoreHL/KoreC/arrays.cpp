#include <Kore/pch.h>
#include <hl.h>

extern "C" vbyte* hl_kore_float32array_alloc(int elements) {
	float* data = new float[elements];
	return (vbyte *)data;
}

extern "C" void hl_kore_float32array_free(vbyte* f32array) {
	delete[] f32array;
}

extern "C" void hl_kore_float32array_set(vbyte* f32array, int index, float value) {
	float* arr = (float*)f32array;
	arr[index] = value;
}

extern "C" float hl_kore_float32array_get(vbyte* f32array, int index) {
	float* arr = (float*)f32array;
	return arr[index];
}

extern "C" vbyte* hl_kore_uint32array_alloc(int elements) {
	unsigned int* data = new unsigned int[elements];
	return (vbyte*)data;
}

extern "C" void hl_kore_uint32array_free(vbyte* u32array) {
	delete[] u32array;
}

extern "C" void hl_kore_uint32array_set(vbyte* u32array, int index, unsigned int value) {
	unsigned int* arr = (unsigned int*)u32array;
	arr[index] = value;
}

extern "C" unsigned int hl_kore_uint32array_get(vbyte* u32array, int index) {
	unsigned int* arr = (unsigned int*)u32array;
	return arr[index];
}

extern "C" vbyte* hl_kore_int16array_alloc(int elements) {
	short* data = new short[elements];
	return (vbyte*)data;
}

extern "C" void hl_kore_int16array_free(vbyte* i16array) {
	delete[] i16array;
}

extern "C" void hl_kore_int16array_set(vbyte* i16array, int index, short value) {
	short* arr = (short*)i16array;
	arr[index] = value;
}

extern "C" short hl_kore_int16array_get(vbyte* i16array, int index) {
	short* arr = (short*)i16array;
	return arr[index];
}
