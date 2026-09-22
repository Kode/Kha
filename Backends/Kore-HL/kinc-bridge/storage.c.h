#include <kinc/io/filereader.h>
#include <kinc/io/filewriter.h>

#include <hl.h>

vbyte *hl_kinc_file_read(vbyte *name, int *size) {
	kinc_file_reader_t file;
	if (!kinc_file_reader_open(&file, (char *)name, KINC_FILE_TYPE_SAVE)) {
		return NULL;
	}
	hl_blocking(true);
	int len = (int)kinc_file_reader_size(&file);
	*size = len;
	hl_blocking(false);
	vbyte *content = (vbyte *)hl_gc_alloc_noptr(len);
	hl_blocking(true);
	kinc_file_reader_read(&file, content, len);
	kinc_file_reader_close(&file);
	hl_blocking(false);
	return content;
}

void hl_kinc_file_write(vbyte *name, vbyte *data, int size) {
	kinc_file_writer_t file;
	if (!kinc_file_writer_open(&file, (char *)name)) {
		return;
	}
	hl_blocking(true);
	kinc_file_writer_write(&file, data, size);
	kinc_file_writer_close(&file);
	hl_blocking(false);
}
