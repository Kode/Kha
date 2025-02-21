package kha;

import haxe.io.Bytes;

using StringTools;

@:headerCode("
#include <kinc/io/filereader.h>
#include <kinc/io/filewriter.h>
")
@:ifFeature("kha.Storage.*")
class KoreStorageFile extends StorageFile {
	var name: String;

	public function new(name: String) {
		this.name = name;
	}

	@:functionCode("
		kinc_file_reader_t file;
		if (!kinc_file_reader_open(&file, name, KINC_FILE_TYPE_SAVE)) return null();
		::kha::internal::BytesBlob blob = createBlob(kinc_file_reader_size(&file));
		kinc_file_reader_read(&file, blob->bytes->b->Pointer(), kinc_file_reader_size(&file));
		kinc_file_reader_close(&file);
		return blob;
	")
	override public function read(): Blob {
		return null;
	}

	@:functionCode("
		kinc_file_writer_t file;
		if (!kinc_file_writer_open(&file, name)) return;
		kinc_file_writer_write(&file, data->bytes->b->Pointer(), data->get_length());
		kinc_file_writer_close(&file);
	")
	function writeInternal(data: Blob): Void {}

	override public function write(data: Blob): Void {
		if (data != null) {
			writeInternal(data);
		}
	}

	@:keep
	static function createBlob(size: Int): Blob {
		return Blob.alloc(size);
	}

	static function unused(): Void {
		Bytes.alloc(0);
	}
}

class Storage {
	public static function namedFile(name: String): StorageFile {
		name = name.replace("\\", ".");
		name = name.replace("/", ".");
		return new KoreStorageFile(name);
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
