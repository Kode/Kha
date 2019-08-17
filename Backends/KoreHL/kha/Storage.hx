package kha;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesData;

using StringTools;

@:ifFeature("kha.Storage.*")
class KoreStorageFile extends StorageFile {
	private var name: String;

	public function new(name: String) {
		this.name = name;
	}

	override public function read(): Blob {
		final bytes = StringHelper.convert(name);
		final b: hl.Bytes = readInternal(bytes);
		final size = readInternalSize();
		if (size == 0) return null;
		final bd = new BytesData(b, size);
		return Blob.fromBytes(Bytes.ofData(bd));
	}
	
	@:hlNative("std", "kore_storage_file_read")
	static function readInternal(name: hl.Bytes): hl.Bytes {
		return null;
	}
	
	@:hlNative("std", "kinc_get_save_file_size")
	static function readInternalSize(): Int {
		return 0;
	}

	@:hlNative("std", "kore_storage_write")
	static function writeInternal(name: hl.Bytes, data: hl.Bytes, length: Int): Void {}

	override public function write(data: Blob): Void {
		if (data != null) {
			final bytes = StringHelper.convert(name);
			final length = data.toBytes().length;
			final data = hl.Bytes.fromBytes(data.toBytes());
			writeInternal(bytes, data, length);
		}
	}

	@:keep
	private static function createBlob(size: Int): Blob {
		return Blob.alloc(size);
	}

	private static function unused(): Void {
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
