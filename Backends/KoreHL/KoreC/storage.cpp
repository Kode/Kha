#include <Kore/pch.h>
#include <kinc/system.h>
#include <hl.h>

extern "C" vbyte* hl_kore_storage_file_read(vbyte *name) {
	kinc_load_save_file((char*)name);
	return (vbyte*)kinc_get_save_file();
}

extern "C" int hl_kinc_get_save_file_size() {
	return (int)kinc_get_save_file_size();
}

extern "C" void hl_kore_storage_write(vbyte *name, vbyte *data, int length) {
	kinc_save_save_file((char*)name, (uint8_t*)data, (size_t)length);
}

